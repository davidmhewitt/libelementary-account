/*
 * Copyright 2020 elementary, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class CardRow : Gtk.ListBoxRow {
    public ElementaryAccount.Card card { get; construct; }
    public Gtk.Revealer close_revealer { get; private set; }

    private static Gtk.CssProvider css_provider;

    public CardRow (ElementaryAccount.Card card) {
        Object (card: card);
    }

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("io/elementary/switchboard/wallet/SecretItemRow.css");
    }

    construct {
        var delete_image = new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
        delete_image.get_style_context ().add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var delete_button = new Gtk.Button ();
        delete_button.image = delete_image;
        delete_button.margin_start = 6;
        delete_button.tooltip_text = (_("Delete"));
        delete_button.valign = Gtk.Align.CENTER;

        unowned Gtk.StyleContext delete_button_context = delete_button.get_style_context ();
        delete_button_context.add_class ("delete");
        delete_button_context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        close_revealer = new Gtk.Revealer ();
        close_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
        close_revealer.add (delete_button);

        var image = new Gtk.Image.from_icon_name ("payment-card", Gtk.IconSize.DND);
        image.use_fallback = true;

        var brand_title = "%c%s".printf (card.brand[0].toupper (), card.brand[1:card.brand.length]);
        var title_label = new Gtk.Label (_("%s ending %s").printf (brand_title, card.last_four));
        title_label.hexpand = true;
        title_label.xalign = 0;

        var description = new Gtk.Label (null);
        description.use_markup = true;
        description.xalign = 0;

        var grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.margin = 6;
        grid.margin_start = 0;
        grid.attach (close_revealer, 0, 0, 1, 2);
        grid.attach (image, 1, 0, 1, 2);
        grid.attach (title_label, 2, 0);
        grid.attach (description, 2, 1);

        var revealer = new Gtk.Revealer ();
        revealer.reveal_child = true;
        revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        revealer.add (grid);

        add (revealer);

        var exp = "%d/%d".printf(card.exp_month, card.exp_year);
        description.label = "<small>%s</small>".printf (_("Expires %s").printf (exp));

        image.icon_name = "payment-card-%s".printf (card.brand.down ());

        delete_button.button_release_event.connect (() => {
            revealer.transition_duration = 195;
            revealer.reveal_child = false;

            GLib.Timeout.add (revealer.transition_duration, () => {
                delete_card ();
                return false;
            });
        });

        focus_out_event.connect (() => {
            close_revealer.reveal_child = false;
        });
    }

    private void delete_card () {
        card.delete ();
        destroy ();
    }
}

