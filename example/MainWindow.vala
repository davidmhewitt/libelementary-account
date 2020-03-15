public class MainWindow : Gtk.Window {
    private const string CLIENT_ID ="1oUZ7k1x32M3nMhU8wcbrN8Y";

    private ElementaryAccount.AccountManager account;

    private Gtk.Label status_label;
    private Gtk.Button login_button;
    private Gtk.ListBox listbox;

    construct {
        set_default_size (1024, 768);

        account = new ElementaryAccount.AccountManager ();
        account.loaded.connect (on_account_loaded);
        destroy.connect (Gtk.main_quit);

        status_label = new Gtk.Label (_("Status:"));

        login_button = new Gtk.Button.with_label (_("Login"));
        login_button.sensitive = false;
        login_button.clicked.connect (do_login_flow);

        var cards_label = new Gtk.Label (_("Cards:"));

        var content_grid = new Gtk.Grid ();
        content_grid.orientation = Gtk.Orientation.VERTICAL;
        content_grid.margin = 12;
        content_grid.hexpand = true;
        content_grid.column_spacing = 12;
        content_grid.row_spacing = 6;

        var placeholder = new Granite.Widgets.AlertView (
            _("Save payment methods for later"),
            _("Add payment methods to Wallet by clicking the icon in the toolbar below."),
            ""
        );
        placeholder.show_all ();

        listbox = new Gtk.ListBox ();
        listbox.activate_on_single_click = false;
        listbox.expand = true;
        listbox.selection_mode = Gtk.SelectionMode.MULTIPLE;
        listbox.set_placeholder (placeholder);

        listbox.selected_rows_changed.connect (() => {
            foreach (unowned Gtk.Widget row in listbox.get_children ()) {
                ((CardRow) row).close_revealer.reveal_child = ((CardRow) row).is_selected ();
            }
        });

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (listbox);

        var add_button = new Gtk.Button.with_label (_("Add Payment Method…"));
        add_button.always_show_image = true;
        add_button.image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        add_button.margin = 3;
        add_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        add_button.clicked.connect (do_add_card_flow);

        var action_bar = new Gtk.ActionBar ();
        action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        action_bar.add (add_button);

        var pay_button = new Gtk.Button.with_label (_("Start Purchase"));
        pay_button.clicked.connect (do_purchase_flow);

        content_grid.add (status_label);
        content_grid.add (login_button);
        content_grid.add (cards_label);
        content_grid.add (scrolled_window);
        content_grid.add (action_bar);
        content_grid.add (pay_button);

        add (content_grid);

        show_all ();
    }

    private void on_account_loaded (bool has_token) {
        status_label.label = has_token ? "Status: Logged In" : "Status: Logged Out";
        login_button.sensitive = !has_token;

        if (has_token) {
            reload_cards ();
        }
    }

    private void reload_cards () {
        listbox.foreach ((element) => element.destroy ());

        var cards = account.get_cards ();
        foreach (var card in cards) {
            var row = new CardRow (card);
            listbox.add (row);
        }

        listbox.show_all ();
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
        var selected_card = (listbox.get_selected_row () as CardRow);
        if (selected_card != null) {
            var purchase_flow = new PurchaseFlow (account, selected_card.card.stripe_id);
            purchase_flow.finished.connect (() => {
                purchase_flow.destroy ();
            });
        }
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        var window = new MainWindow ();
        window.show_all ();

        Gtk.main ();
        return 0;
    }
}
