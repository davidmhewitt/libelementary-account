namespace ElementaryAccount {
    public class NativeWebView : WebKit.WebView {
        public signal void success (string code);

        public NativeWebView () {
            Object (user_content_manager: new WebKit.UserContentManager ());
        }

        construct {
            var css = new WebKit.UserStyleSheet (
                """
                html,
                body {
                    background-color: #f5f5f5;
                    color: #333;
                    font-family: Inter, "Open Sans", sans-serif;
                }
                """,
                WebKit.UserContentInjectedFrames.TOP_FRAME,
                WebKit.UserStyleLevel.USER,
                null,
                null
            );

            user_content_manager.add_style_sheet (css);

            var new_settings = new WebKit.Settings ();
            new_settings.default_font_family = Gtk.Settings.get_default ().gtk_font_name;

            settings = new_settings;

            expand = true;

            load_changed.connect ((load_event) => {
                if (load_event == WebKit.LoadEvent.FINISHED) {
                    var title = get_title ();
                    if (title != null) {
                        var split = title.split("=");
                        if (split.length == 2 && split[0] == "Success code") {
                            var auth_code = split[1];
                            success (auth_code);
                        }
                    }
                }
            });
        }

        public void get_with_bearer (string uri, string bearer) {
            var request = new WebKit.URIRequest (uri);
            unowned Soup.MessageHeaders headers = request.get_http_headers ();
            headers.append ("Authorization", "Bearer %s".printf (bearer));

            load_request (request);
        }
    }
}
