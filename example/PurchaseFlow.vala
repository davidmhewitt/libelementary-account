public class PurchaseFlow : Gtk.Window {
    public signal void finished ();

    public ElementaryAccount.AccountManager account { get; construct; }
    public string? payment_method_id { get; construct; }

    private const string URL = "/intents/do_charge?amount=500&stripe_account=acct_1AWVFSHS6fmgRLTb&payment_method=%s";

    public PurchaseFlow (ElementaryAccount.AccountManager manager, string? payment_method_id) {
        Object (account: manager, payment_method_id: payment_method_id);
    }

    construct {
        set_default_size (500, 500);

        do_payment_flow ();
    }

    private void do_payment_flow () {
        var webview = new ElementaryAccount.NativeWebView ();
        webview.success.connect (() => finished ());

        var payment_uri = new Soup.URI (ElementaryAccount.Utils.get_api_uri ("/intents/do_charge"));
        if (payment_method_id != null) {
            payment_uri.set_query_from_fields (
                "amount", "500",
                "stripe_account", "acct_1AWVFSHS6fmgRLTb",
                "payment_method", payment_method_id
            );
        } else {
            payment_uri.set_query_from_fields (
                "amount", "500",
                "stripe_account", "acct_1AWVFSHS6fmgRLTb"
            );
        }

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
