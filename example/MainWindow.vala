public class MainWindow : Gtk.Window {
    private ElementaryAccount.AccountManager account;
    private ElementaryAccount.CardListView cards_list;

    private Gtk.Label status_label;
    private Gtk.Button login_button;

    private bool logged_in = false;

    construct {
        set_default_size (1024, 768);

        account = new ElementaryAccount.AccountManager ();
        account.auth_state_changed.connect (on_auth_state_changed);
        account.check_authenticated.begin ();
        destroy.connect (Gtk.main_quit);

        status_label = new Gtk.Label (_("Status:"));

        login_button = new Gtk.Button.with_label (_("Login"));
        login_button.sensitive = false;
        login_button.clicked.connect (do_login_flow);

        cards_list = new ElementaryAccount.CardListView ();
        cards_list.add_card.connect (do_add_card_flow);

        var content_grid = new Gtk.Grid ();
        content_grid.orientation = Gtk.Orientation.VERTICAL;
        content_grid.margin = 12;
        content_grid.hexpand = true;
        content_grid.column_spacing = 12;
        content_grid.row_spacing = 6;

        var pay_button = new Gtk.Button.with_label (_("Start Purchase"));
        pay_button.clicked.connect (do_purchase_flow);

        content_grid.add (status_label);
        content_grid.add (login_button);
        content_grid.add (cards_list);
        content_grid.add (pay_button);

        add (content_grid);

        show_all ();
    }

    private void on_auth_state_changed (bool has_token) {
        logged_in = has_token;

        status_label.label = has_token ? "Status: Logged In" : "Status: Logged Out";
        login_button.sensitive = !has_token;

        if (has_token) {
            reload_cards ();
        }
    }

    private void reload_cards () {
        cards_list.load_cards (account.get_cards ());
    }

    private void do_login_flow () {
        var login_flow = new LoginFlow (account);
        login_flow.finished.connect (() => {
            login_flow.destroy ();
        });
    }

    private void do_add_card_flow () {
        var card_flow = new AddCardFlow (account);
        card_flow.finished.connect (() => {
            card_flow.destroy ();
            reload_cards ();
        });
    }

    private void do_purchase_flow () {
        var card = cards_list.get_selected_card ();

        string? anon_id = null;
        if (!logged_in) {
            anon_id = ElementaryAccount.Utils.base64_url_encode (ElementaryAccount.Utils.generate_random_bytes (32));
        }

        var purchase_flow = new PurchaseFlow (account, 500, "com.github.cassidyjames.dippi", card, anon_id);
        purchase_flow.finished.connect (() => {
            purchase_flow.destroy ();
        });
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        var window = new MainWindow ();
        window.show_all ();

        Gtk.main ();
        return 0;
    }
}
