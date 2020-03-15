public class AddCardFlow : Gtk.Window {
    public signal void finished ();

    public ElementaryAccount.AccountManager account { get; construct; }

    public AddCardFlow (ElementaryAccount.AccountManager manager) {
        Object (account: manager);
    }

    construct {
        set_default_size (300, 300);

        do_card_flow ();
    }

    private void do_card_flow () {
        var webview = new ElementaryAccount.NativeWebView ();
        webview.success.connect (() => finished ());

        webview.get_with_bearer ("https://davidmhewitt.pythonanywhere.com/intents/add_card", account.account_token);

        add (webview);

        show_all ();
    }
}
