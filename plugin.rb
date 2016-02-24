# name: discourse-anonymous-categories
# about: Always-anonymous categories for Discourse
# version: 0.1.0
# authors: Jared Reisinger
# url: https://github.com/JaredReisinger/discourse-anonymous-categories

enabled_site_setting :anonymous_categories_enabled

after_initialize do

  require_dependency 'category'
  require_dependency 'guardian'
  require_dependency 'site_setting'
  require_dependency 'user'
  require_dependency 'anonymous_shadow_creator'
  require_dependency 'new_post_result'
  require_dependency 'post_creator'

  class ::Category
      after_save :reset_anonymous_categories_cache

      protected
      def reset_anonymous_categories_cache
        ::Guardian.reset_anonymous_categories_cache
      end
  end

  class ::Guardian
    @@anonymous_categories_cache = DistributedCache.new("anonymous_categories")

    def self.reset_anonymous_categories_cache
      @@anonymous_categories_cache["allowed"] =
        begin
          Set.new(
            CategoryCustomField
              .where(name: "force_anonymous_posting", value: "true")
              .pluck(:category_id)
          )
        end
    end
  end

  @anon_handler = lambda do |manager|
    if !SiteSetting.anonymous_categories_enabled
      return nil
    end

    user = manager.user
    args = manager.args

    # Note that an uncategorized topic post comes through as an empty category
    # rather than category "1".  We need to special case this for now...
    category_id = args[:category]
    category_id = SiteSetting.uncategorized_category_id.to_s if category_id.blank?

    # Have to figure out what category the post is in to see if it needs to be
    # anonymized.
    category = Category.find(category_id)

    if category.custom_fields["force_anonymous_posting"] != "true"
      return nil
    end

    # Bypass the global anonymous setting for this post/category in order to
    # force it.
    shadow = nil
    if (shadow_id = user.custom_fields["shadow_id"].to_i) > 0
      shadow = User.find_by(id: shadow_id)

      if shadow && shadow.post_count > 0 &&
          shadow.last_posted_at < SiteSetting.anonymous_account_duration_minutes.minutes.ago
        shadow = nil
      end
    end

    anon_user = shadow || AnonymousShadowCreator.create_shadow(user)

    # The client-side UI seems to get upset if the returned post was made by
    # "another" user, and will refuse to clear the field.  Instead, we act as
    # though this is a queued post, and that's enough to reset the UI.  It also
    # happens to give us an opportunity to point out that the post has been
    # automatically anonymized!  (See NewPostManager.perform_create_post for the
    # logic we're replicating here.)
    result = NewPostResult.new(:enqueued)
    creator = PostCreator.new(anon_user, args)
    post = creator.create
    result.check_errors_from(creator)

    if result.success?
      result.queued_post = post
      result.pending_count = 0
      result.reason = :force_anonymous_post
    else
      user.flag_linked_posts_as_spam if creator.spam?
    end

    return result
  end

  NewPostManager.add_handler(&@anon_handler)

end
