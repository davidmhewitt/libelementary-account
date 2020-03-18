public class PurchaseFlow : Gtk.Window {
    public signal void finished ();

    public ElementaryAccount.AccountManager account { get; construct; }
    public ElementaryAccount.Card? payment_method { get; construct; }
    public string app_id { get; construct; }
    public int amount { get; construct; }
    public string anon_id { get; construct; }

    public PurchaseFlow (ElementaryAccount.AccountManager manager, int amount, string app_id, ElementaryAccount.Card? payment_method, string? anon_id) {
        Object (
            account: manager,
            payment_method: payment_method,
            app_id: app_id,
            amount: amount,
            anon_id: anon_id
        );
    }

    construct {
        set_default_size (500, 400);

        do_payment_flow ();
    }

    private void do_payment_flow () {
        var webview = new ElementaryAccount.NativeWebView ();
        webview.success.connect (() => finished ());

        var payment_uri = new Soup.URI (ElementaryAccount.Utils.get_api_uri ("/intents/do_charge"));

        var args = new GLib.HashTable<string, string>(str_hash, str_equal);
        args.insert ("amount", amount.to_string ());
        args.insert ("app_id", app_id);
        args.insert ("stripe_account", "acct_1AWVFSHS6fmgRLTb");

        if (payment_method != null) {
            args.insert ("payment_method", payment_method.stripe_id);
        }

        if (anon_id != null) {
            args.insert ("anon_id", anon_id);
        }

        payment_uri.set_query_from_form (args);

        var payment_url = payment_uri.to_string (false);
        if (account.account_token != null) {
            webview.get_with_bearer (payment_url, account.account_token);
        } else {
            webview.load_uri (payment_url);
        }

        add (webview);

        show_all ();
    }
}
