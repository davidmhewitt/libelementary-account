namespace ElementaryAccount {
    public class AccountManager : GLib.Object {
        public signal void loaded (bool token_found);
        public string? account_token { get; private set; }
        private Secret.Collection collection;

        private Soup.Session soup_session;

        construct {
            soup_session = new Soup.Session ();
            find_tokens.begin ();
        }

        public async void find_tokens () {
            try {
                collection = yield Secret.Collection.for_alias (null, Secret.COLLECTION_DEFAULT, Secret.CollectionFlags.LOAD_ITEMS, null);
            } catch (Error e) {
                critical (e.message);
                return;
            }

            foreach (unowned Secret.Item secret_item in collection.get_items ()) {
                if (secret_item.get_schema_name () == "io.elementary.account") {
                    yield secret_item.load_secret (null);

                    var secret = secret_item.get_secret ().get_text ();

                    if (!test_login (secret)) {
                        secret_item.delete (null);
                        account_token = null;
                    } else {
                        account_token = secret;
                        break;
                    }

                    break;
                }
            }

            loaded (account_token != null);
        }

        private bool test_login (string token) {
            var base_uri = new Soup.URI (Constants.BASE_URL);
            var card_uri = new Soup.URI.with_base (base_uri, "/api/me");
            var message = new Soup.Message.from_uri ("GET", card_uri);
            message.request_headers.append ("Authorization", "Bearer %s".printf (token));

            soup_session.send_message (message);

            if (message.status_code == 200) {
                return true;
            }

            return false;
        }

        public void exchange_code_for_token (string url, string code, string? verifier = null) {
            string body;
            if (verifier != null) {
                body = Soup.Form.encode (
                    "grant_type", "authorization_code",
                    "client_id", Constants.CLIENT_ID,
                    "code_verifier", verifier,
                    "code", code,
                    "redirect_uri", "urn:ietf:wg:oauth:2.0:oob"
                );
            } else {
                body = Soup.Form.encode (
                    "grant_type", "authorization_code",
                    "client_id", Constants.CLIENT_ID,
                    "code", code,
                    "redirect_uri", "urn:ietf:wg:oauth:2.0:oob"
                );
            }

            var message = new Soup.Message ("POST", url);
            message.set_request ("application/x-www-form-urlencoded", Soup.MemoryUse.COPY, body.data);

            soup_session.send_message (message);

            var response_body = (string)message.response_body.data;

            var parser = new Json.Parser ();
            parser.load_from_data (response_body, -1);

            var root = parser.get_root ().get_object ();
            if (root.has_member ("access_token")) {
                var token = root.get_string_member ("access_token");

                var schema = new Secret.Schema (
                    "io.elementary.account", Secret.SchemaFlags.NONE,
                    "exp", Secret.SchemaAttributeType.STRING
                );

                // FIXME: Lookup and replace old tokens
                Secret.Item.create.begin (
                    collection,
                    schema,
                    new GLib.HashTable<string, string> (GLib.str_hash, GLib.str_equal),
                    "Auth Token",
                    new Secret.Value (token, -1, "text/plain"),
                    Secret.ItemCreateFlags.NONE,
                    null
                );

                account_token = token;
                loaded (true);
            }
        }

        public void delete_card (Card card) {
            var base_uri = new Soup.URI (Constants.BASE_URL);
            var delete_uri = new Soup.URI.with_base (base_uri, "/api/v1/delete_card/%s".printf (card.stripe_id));
            var message = new Soup.Message.from_uri ("POST", delete_uri);
            message.request_headers.append ("Authorization", "Bearer %s".printf (account_token));

            soup_session.send_message (message);
        }

        public Card[] get_cards () {
            Card[] cards = {};

            if (account_token == null) {
                return cards;
            }

            var base_uri = new Soup.URI (Constants.BASE_URL);
            var card_uri = new Soup.URI.with_base (base_uri, "/api/v1/cards");
            var message = new Soup.Message.from_uri ("GET", card_uri);
            message.request_headers.append ("Authorization", "Bearer %s".printf (account_token));

            soup_session.send_message (message);

            var response_body = (string)message.response_body.data;

            var parser = new Json.Parser ();
            parser.load_from_data (response_body, -1);

            var root = parser.get_root ().get_object ();
            if (root.has_member ("sources")) {
                unowned Json.Array source_array = root.get_array_member ("sources");
                source_array.foreach_element ((arr, index, source) => {
                    unowned Json.Object source_obj = source.get_object ();
                    if (source_obj.has_member ("card")) {
                        unowned Json.Object card_obj = source_obj.get_object_member ("card");
                        int exp_month = (int)card_obj.get_int_member ("exp_month");
                        int exp_year = (int)card_obj.get_int_member ("exp_year");
                        string last4 = card_obj.get_string_member ("last4");
                        string brand = card_obj.get_string_member ("brand");
                        string id = source_obj.get_string_member ("id");
                        cards += new Card (brand, last4, exp_month, exp_year, id, this);
                    }
                });
            }

            return cards;
        }
    }
}
