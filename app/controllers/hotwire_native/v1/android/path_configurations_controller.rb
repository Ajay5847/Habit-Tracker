class HotwireNative::V1::Android::PathConfigurationsController < ActionController::Base
  def show
    render json:
      {
        "settings": {
          "version": "v1"
        },
        "rules": [
          {
            "patterns": [
              ".*"
            ],
            "properties": {
              "context": "default",
              "uri": "hotwire://fragment/web",
              "pull_to_refresh_enabled": true
            }
          },
          {
            "patterns": [
              "/habits/lists/\\d+/items/\\d+$",
              "/habits/lists/\\d+/items$",
              "/habits/lists/\\d+$"
            ],
            "properties": {
              "context": "default",
              "uri": "hotwire://fragment/web",
              "presentation": "push",
              "pull_to_refresh_enabled": true
            }
          },
          {
            "patterns": [
              "/users/sign_in$",
              "/users/sign_up$",
              "/users/passwords/.*$"
            ],
            "properties": {
              "context": "default",
              "uri": "hotwire://fragment/web",
              "presentation": "replace_root",
              "pull_to_refresh_enabled": true
            }
          },
          {
            "patterns": [
              "/jobs/.*$"
            ],
            "properties": {
              "context": "default",
              "uri": "hotwire://fragment/web",
              "presentation": "external",
              "pull_to_refresh_enabled": false
            }
          }
        ]
      }
  end
end
