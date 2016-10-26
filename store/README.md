# w5d2-store

*EXPLORER MODE*

1. How many users are there?
```
  User.count
    (0.3ms)  SELECT COUNT(*) FROM "users"
  => 50
```
2. What are the 5 most expensive items?
```
  Item.order(:price).last(5)
    Item Load (2.4ms)  SELECT  "items".* FROM "items" ORDER BY "items"."price" DESC LIMIT ?  [["LIMIT", 5]]
  => [#<Item:0x007fea82a41a40 id: 60, title: "Ergonomic Steel Car", category: "Books & Outdoors", description: "Enterprise-wide secondary firmware", price: 9341>,
   #<Item:0x007fea82a422b0 id: 40, title: "Sleek Wooden Hat", category: "Music & Baby", description: "Quality-focused heuristic info-mediaries", price: 9390>,
   #<Item:0x007fea82a50158 id: 100, title: "Awesome Granite Pants", category: "Toys & Books", description: "Upgradable 24/7 access", price: 9790>,
   #<Item:0x007fea82a508b0 id: 83, title: "Small Wooden Computer", category: "Health", description: "Re-engineered fault-tolerant adapter", price: 9859>,
   #<Item:0x007fea82a522f0 id: 25, title: "Small Cotton Gloves", category: "Automotive, Shoes & Beauty", description: "Multi-layered modular service-desk", price: 9984>]
```
3. What's the cheapest book? (Does that change for "category is exactly 'book'" versus "category contains 'book'"?)
```
  Item.where(category: "Books").order(:price).first
    Item Load (0.3ms)  SELECT  "items".* FROM "items" WHERE "items"."category" = ? ORDER BY "items"."price" ASC LIMIT ?  [["category", "Books"], ["LIMIT", 1]]
  => #<Item:0x007fea82ebb120 id: 76, title: "Ergonomic Granite Chair", category: "Books", description: "De-engineered bi-directional portal", price: 1496>

  Item.where("category LIKE ?", "%Books%").order(:price).first
    Item Load (0.3ms)  `SELECT  "items".* FROM "items" WHERE (category LIKE '%Books%') ORDER BY "items"."price" ASC LIMIT ?  [["LIMIT", 1]]`
  => #<Item:0x007fea82148560 id: 76, title: "Ergonomic Granite Chair", category: "Books", description: "De-engineered bi-directional portal", price: 1496>
```
4. Who lives at "6439 Zetta Hills, Willmouth, WY"? Do they have another address?
```
  User.joins(:addresses).where('addresses.street' => '6439 Zetta Hills')
    User Load (0.2ms) SELECT "users".* FROM "users" INNER JOIN "addresses" ON "addresses"."user_id" = "users"."id" WHERE "addresses"."street" = ?  [["street", "6439 Zetta Hills"]]
  => [#<User:0x007fd6c63b2c58 id: 40, first_name: "Corrine", last_name: "Little", email: "rubie_kovacek@grimes.net">]

  Address.joins(:user).where('users.first_name' => 'Corrine', 'users.last_name' => 'Little')
   Address Load (0.2ms)  SELECT "addresses".* FROM "addresses" INNER JOIN "users" ON "users"."id" = "addresses"."user_id" WHERE "users"."first_name" = ? AND "users"."last_name" = ?  [["first_name", "Corrine"], ["last_name", "Little"]]
  => [#<Address:0x007fd6c8779ad8 id: 43, user_id: 40, street: "6439 Zetta Hills", city: "Willmouth", state: "WY", zip: 15029>,
  #<Address:0x007fd6c87798a8 id: 44, user_id: 40, street: "54369 Wolff Forges", city: "Lake Bryon", state: "CA", zip: 31587>]
```
5. Correct Virginie Mitchell's address to "New York, NY, 10108".
```
  user = User.find_by('first_name' => 'Virginie', 'last_name' => 'Mitchell')
    User Load (0.3ms)  SELECT  "users".* FROM "users" WHERE "users"."first_name" = ? AND "users"."last_name" = ? LIMIT ?  [["first_name", "Virginie"], ["last_name", "Mitchell"], ["LIMIT", 1]]
  => #<User:0x007fd6c876b280 id: 39, first_name: "Virginie", last_name: "Mitchell", email: "daisy.crist@altenwerthmonahan.biz">

  user.addresses.update(city: 'New York', state: 'NY', zip: '10108')
    Address Load (0.2ms)  SELECT "addresses".* FROM "addresses" WHERE "addresses"."user_id" = ?  [["user_id", 39]]
    (0.1ms)  begin transaction
        SQL (0.5ms)  UPDATE "addresses" SET "city" = ?, "zip" = ? WHERE "addresses"."id" = ?  [["city", "New York"], ["zip", 10108], ["id", 41]]
    (0.7ms)  commit transaction
    (0.1ms)  begin transaction
        SQL (0.8ms)  UPDATE "addresses" SET "city" = ?, "state" = ?, "zip" = ? WHERE "addresses"."id" = ?  [["city", "New York"], ["state", "NY"], ["zip", 10108], ["id", 42]]
    (1.1ms)  commit transaction
  => [#<Address:0x007fd6c8440da8 id: 41, user_id: 39, street: "12263 Jake Crossing", city: "New York", state: "NY", zip: 10108>,
  #<Address:0x007fd6c8440c68 id: 42, user_id: 39, street: "83221 Mafalda Canyon", city: "New York", state: "NY", zip: 10108>]
```
6. How much would it cost to buy one of each tool?
```
  Item.where('category like ?', '%tool%').sum('items.price')
    (0.2ms)  SELECT SUM(items.price) FROM "items" WHERE (category like '%tool%')
  => 46477
```
7. How many total items did we sell?
```
  Order.sum(:quantity)
    (2.2ms)  SELECT SUM("orders"."quantity") FROM "orders"
  => 2125
```
8. How much was spent on books?
```
  Order.joins(:item).where('items.category like ?', '%book%').sum('items.price * orders.quantity')
   (0.7ms)  SELECT SUM(items.price * orders.quantity) FROM "orders" INNER JOIN "items" ON "items"."id" = "orders"."item_id" WHERE (items.category like '%book%')
  => 1081352
```
9. Simulate buying an item by inserting a User for yourself and an Order for that User.
```
  User.create(first_name: 'Chris', last_name: 'Flack', email: 'ccflack@me.com')
    (0.1ms)  begin transaction
      SQL (2.6ms)  INSERT INTO "users" ("first_name", "last_name", "email") VALUES (?, ?, ?)  [["first_name", "Chris"], ["last_name", "Flack"], ["email", "ccflack@me.com"]]
    (0.8ms)  commit transaction
  => #<User:0x007fd6c62e27b0 id: 51, first_name: "Chris", last_name: "Flack", email: "ccflack@me.com">

  Order.create(user_id: '51', item_id: '28', quantity: '3', created_at: Time.now)
    (0.1ms)  begin transaction
        User Load (0.1ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 51], ["LIMIT", 1]]
        Item Load (0.1ms)  SELECT  "items".* FROM "items" WHERE "items"."id" = ? LIMIT ?  [["id", 28], ["LIMIT", 1]]
        SQL (1.5ms)  INSERT INTO "orders" ("user_id", "item_id", "quantity", "created_at") VALUES (?, ?, ?, ?)  [["user_id", 51], ["item_id", 28], ["quantity", 3], ["created_at", 2016-10-25 20:51:23 UTC]]
    (3.2ms)  commit transaction
  => #<Order:0x007fd6c5734850 id: 378, user_id: 51, item_id: 28, quantity: 3, created_at: Tue, 25 Oct 2016 20:51:23 UTC +00:00>
```
*ADVENTURE MODE*

1. What item was ordered most often? Grossed the most money?
```
  Item.joins(:orders).select(:title, 'SUM (orders.quantity)').group(:title).order('SUM (orders.quantity)').last
    Item Load (0.7ms)  SELECT  "items"."title", SUM (orders.quantity) FROM "items" INNER JOIN "orders" ON "orders"."item_id" = "items"."id" GROUP BY "items"."title" ORDER BY SUM (orders.quantity) DESC LIMIT ?  [["LIMIT", 1]]
  => #<Item:0x007fab219181c8 id: nil, title: "Incredible Granite Car">

  Item.joins(:orders).select('items.title', 'SUM (items.price * orders.quantity)').group('items.title').order('SUM (items.price * orders.quantity)').last
    Item Load (0.8ms)  SELECT  items.title, SUM (items.price * orders.quantity) FROM "items" INNER JOIN "orders" ON "orders"."item_id" = "items"."id" GROUP BY items.title ORDER BY SUM (items.price * orders.quantity) DESC LIMIT ?  [["LIMIT", 1]]
  => #<Item:0x007fab1e3ceeb8 id: nil, title: "Incredible Granite Car">
```
2. What user spent the most?
```
  Order.joins(:item).joins(:user).select('users.\*').group(:user_id).order('SUM (items.price * orders.quantity)').last
    Order Load (2.9ms)  SELECT  users.* FROM "orders" INNER JOIN "items" ON "items"."id" = "orders"."item_id" INNER JOIN "users" ON "users"."id" = "orders"."user_id" GROUP BY "orders"."user_id" ORDER BY SUM (items.price * orders.quantity) DESC LIMIT ?  [["LIMIT", 1]]
  => #<Order:0x007fab1fc7c460 id: 19>

  User.select('\*').find(19)
    User Load (0.2ms)  SELECT  * FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 19], ["LIMIT", 1]]
  => #<User:0x007fab1fcbc100 id: 19, first_name: "Hassan", last_name: "Runte", email: "weston.kautzer@hoppe.biz">
```
3. What were the top 3 highest grossing categories?
```
  Item.joins(:orders).select(:category).group(:category).order('SUM (items.price * orders.quantity)').last(3)
    Item Load (1.0ms)  SELECT  "items"."category" FROM "items" INNER JOIN "orders" ON "orders"."item_id" = "items"."id" GROUP BY "items"."category" ORDER BY SUM (items.price * orders.quantity) DESC LIMIT ?  [["LIMIT", 3]]
  => [#<Item:0x007fab1dd32550 id: nil, category: "Sports">, #<Item:0x007fab1dd326b8 id: nil, category: "Beauty, Toys & Sports">, #<Item:0x007fab1dd32820 id: nil, category: "Music, Sports & Clothing">]
```
*EPIC MODE*

1. Create table
```
sqlite> CREATE TABLE reviews(
   ...> ID INTEGER PRIMARY KEY AUTOINCREMENT,
   ...> item_id integer,
   ...> user_id integer,
   ...> rating integer,
   ...> review text
   ...> );
```
 2. Generate model
 ```
 $ rails g model reviews
[WARNING] The model name 'reviews' was recognized as a plural, using the singular 'review' instead. Override with --force-plural or setup custom inflection rules for this noun before running the generator.[^1]
      invoke  active_record
      create    db/migrate/20161026010734_create_reviews.rb
      create    app/models/review.rb
      invoke    test_unit
      create      test/models/review_test.rb
      create      test/fixtures/reviews.yml
```

3. Create reviews
```
[1] pry(main)> Review.create(item_id: '28', user_id: '51', rating: '4', review: 'I ordered 3 of these things. They are pretty neat.')
   (0.1ms)  begin transaction
  SQL (1.0ms)  INSERT INTO "reviews" ("item_id", "user_id", "rating", "review") VALUES (?, ?, ?, ?)  [["item_id", 28], ["user_id", 51], ["rating", 4], ["review", "I ordered 3 of these things. They are pretty neat."]]
   (0.7ms)  commit transaction
=> #<Review:0x007f95942ea9d8 ID: 1, item_id: 28, user_id: 51, rating: 4, review: "I ordered 3 of these things. They are pretty neat.">
[2] pry(main)> Review.create(item_id: '15', user_id: '7', rating: '2', review: 'Actual garbage.')
   (0.1ms)  begin transaction
  SQL (0.4ms)  INSERT INTO "reviews" ("item_id", "user_id", "rating", "review") VALUES (?, ?, ?, ?)  [["item_id", 15], ["user_id", 7], ["rating", 2], ["review", "Actual garbage."]]
   (5.9ms)  commit transaction
=> #<Review:0x007f95917cf640 ID: 2, item_id: 15, user_id: 7, rating: 2, review: "Actual garbage.">
[3] pry(main)> Review.create(item_id: '55', user_id: '11', rating: '5', review: 'Everything is different now.')
   (0.1ms)  begin transaction
  SQL (1.5ms)  INSERT INTO "reviews" ("item_id", "user_id", "rating", "review") VALUES (?, ?, ?, ?)  [["item_id", 55], ["user_id", 11], ["rating", 5], ["review", "Everything is different now."]]
   (7.7ms)  commit transaction
=> #<Review:0x007f9594118dd0 ID: 3, item_id: 55, user_id: 11, rating: 5, review: "Everything is different now.">
```
4. Query reviews
```
  Item.joins(:reviews).joins(:orders).where('orders.quantity > 5')
    Item Load (0.3ms)  SELECT "items".* FROM "items" INNER JOIN "reviews" ON "reviews"."item_id" = "items"."id" INNER JOIN "orders" ON "orders"."item_id" = "items"."id" WHERE (orders.quantity > 5)
  => [#<Item:0x007f95913a8120 id: 55, title: "Ergonomic Cotton Shoes", category: "Beauty & Baby", description: "Vision-oriented secondary matrices", price: 2911>,
   #<Item:0x007f95913a3b98 id: 55, title: "Ergonomic Cotton Shoes", category: "Beauty & Baby", description: "Vision-oriented secondary matrices", price: 2911>,
   #<Item:0x007f95913a34b8 id: 28, title: "Rustic Concrete Computer", category: "Games & Industrial", description: "Customizable attitude-oriented time-frame", price: 2979>]

  [4] pry(main)> Review.select('\*').where('user_id = 11')
    Review Load (0.2ms)  `SELECT * FROM "reviews" WHERE (user_id = 11)`
  => [#<Review:0x007f959068dfd0 ID: 3, item_id: 55, user_id: 11, rating: 5, review: "Everything is different now.">]
```

[^1]: whoops.
