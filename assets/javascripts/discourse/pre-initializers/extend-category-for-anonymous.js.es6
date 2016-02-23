import property from 'ember-addons/ember-computed-decorators';
import Category from 'discourse/models/category';

export default {
  name: 'extend-category-for-anonymous',
  before: 'inject-discourse-objects',
  initialize() {

    Category.reopen({

      @property('custom_fields.force_anonymous_posting')
      force_anonymous_posting: {
        get(forceField) {
          return forceField === "true";
        },
        set(value) {
          value = value ? "true" : "false";
          this.set("custom_fields.force_anonymous_posting", value);
          return value;
        }
      }

    });
  }
};
