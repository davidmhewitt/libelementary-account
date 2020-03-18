public class LoginFlow : Gtk.Window {
    public signal void finished ();

    private string verifier;

    public ElementaryAccount.AccountManager account { get; construct; }

    public LoginFlow (ElementaryAccount.AccountManager manager) {
        Object (account: manager);
    }

    construct {
        set_default_size (300, 300);

        do_login_flow ();
    }

    private void do_login_flow () {
        var webview = new ElementaryAccount.NativeWebView ();

        verifier = ElementaryAccount.Utils.base64_url_encode (ElementaryAccount.Utils.generate_random_bytes (32));
        var challenge = ElementaryAccount.Utils.base64_url_encode (ElementaryAccount.Utils.sha256 (verifier.data));

        warning ("verifier: %s", verifier);
        warning ("challenge: %s", challenge);

        var constructed_uri = new Soup.URI (ElementaryAccount.Utils.get_api_uri ("/oauth/authorize"));
        constructed_uri.set_query_from_fields (
            "client_id", ElementaryAccount.Constants.CLIENT_ID,
            "scope", "profile",
            "response_type", "code",
            "redirect_uri", "urn:ietf:wg:oauth:2.0:oob",
            "code_challenge", challenge,
            "code_challenge_method", "S256"
        );

        webview.load_uri (constructed_uri.to_string (false));
        webview.success.connect (on_code_received);

        add (webview);

        show_all ();
    }

    private void on_code_received (string code) {
        warning ("Login succeeded with code: %s", code);

        account.exchange_code_for_token (ElementaryAccount.Utils.get_api_uri ("/oauth/token"), code, verifier);

        finished ();
    }
}
