namespace ElementaryAccount {
    public class CardListView : Gtk.Frame {
        public signal void add_card ();

        private Gtk.ListBox listbox;

        construct {
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

            add_button.clicked.connect (() => add_card ());

            var action_bar = new Gtk.ActionBar ();
            action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
            action_bar.add (add_button);

            var grid = new Gtk.Grid ();
            grid.attach (scrolled_window, 0, 0);
            grid.attach (action_bar, 0, 1);

            add (grid);
        }

        public void load_cards (Card[] cards) {
            listbox.foreach ((element) => element.destroy ());

            foreach (var card in cards) {
                var row = new CardRow (card);
                listbox.add (row);
            }

            listbox.show_all ();
        }
    }
}
