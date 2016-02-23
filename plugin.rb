# name: discourse-anonymous-categories
# about: Always-anonymous categories for Discourse
# version: 0.0.1
# authors: Jared Reisinger
# url: https://githiub.com/JaredReisinger/discourse-anonymous-categories

enabled_site_setting :anonymous_categories_enabled

after_initialize do

  @anon_handler = lambda do |manager|
    if SiteSetting.anonymous_categories.include?(manager.args[:category])
      user = manager.user
      args = manager.args

      # Jump around the global anonymous setting for this post...
      shadow = nil
      if (shadow_id = user.custom_fields["shadow_id"].to_i) > 0
        shadow = User.find_by(id: shadow_id)

        if shadow && shadow.post_count > 0 &&
            shadow.last_posted_at < SiteSetting.anonymous_account_duration_minutes.minutes.ago
          shadow = nil
        end
      end

      anon_user = shadow || AnonymousShadowCreator.create_shadow(user)

      # args[:acting_user] = user

      # duplicate logic (yech!) from NewPostManager.perform_create_post
      # can we just use that directly without becoming re-entrant here?
      result = NewPostResult.new(:enqueued)
      creator = PostCreator.new(anon_user, args)
      post = creator.create
      result.check_errors_from(creator)

      if result.success?
        result.queued_post = post
        result.pending_count = 0
        result.reason = :anonymous_category_post
      else
        user.flag_linked_posts_as_spam if creator.spam?
      end

      return result
    end

    return nil
  end

  NewPostManager.add_handler(&@anon_handler)

end
