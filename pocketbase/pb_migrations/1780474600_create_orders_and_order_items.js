/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Create orders collection
  const orders = new Collection({
    "id": "pbc_orders_999999",
    "name": "orders",
    "type": "base",
    "listRule": "@request.auth.id != ''",
    "viewRule": "@request.auth.id != ''",
    "createRule": "@request.auth.id != ''",
    "updateRule": "@request.auth.id != ''",
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "[a-z0-9]{15}",
        "name": "id",
        "primaryKey": true,
        "required": true,
        "type": "text"
      },
      {
        "name": "user_id",
        "type": "relation",
        "required": true,
        "collectionId": "_pb_users_auth_",
        "cascadeDelete": false,
        "maxSelect": 1
      },
      {
        "name": "outlet_id",
        "type": "relation",
        "required": true,
        "collectionId": "pbc_2614074337",
        "cascadeDelete": false,
        "maxSelect": 1
      },
      {
        "name": "order_type",
        "type": "select",
        "required": true,
        "values": ["delivery", "pickup", "dinein"],
        "maxSelect": 1
      },
      {
        "name": "status",
        "type": "select",
        "required": true,
        "values": ["pending_payment", "processing", "dispatched", "completed", "cancelled"],
        "maxSelect": 1
      },
      {
        "name": "delivery_address",
        "type": "text",
        "required": false
      },
      {
        "name": "subtotal",
        "type": "number",
        "required": false
      },
      {
        "name": "delivery_fee",
        "type": "number",
        "required": false
      },
      {
        "name": "discount_fee",
        "type": "number",
        "required": false
      },
      {
        "name": "total_payment",
        "type": "number",
        "required": false
      },
      {
        "name": "payment_method",
        "type": "text",
        "required": false
      },
      {
        "name": "payment_gateway_trx_id",
        "type": "text",
        "required": false
      },
      {
        "name": "created",
        "type": "autodate",
        "onCreate": true
      },
      {
        "name": "updated",
        "type": "autodate",
        "onCreate": true,
        "onUpdate": true
      }
    ]
  });
  app.save(orders);

  // Create order_items collection
  const orderItems = new Collection({
    "id": "pbc_order_items_999",
    "name": "order_items",
    "type": "base",
    "listRule": "@request.auth.id != ''",
    "viewRule": "@request.auth.id != ''",
    "createRule": "@request.auth.id != ''",
    "updateRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "[a-z0-9]{15}",
        "name": "id",
        "primaryKey": true,
        "required": true,
        "type": "text"
      },
      {
        "name": "order_id",
        "type": "relation",
        "required": true,
        "collectionId": "pbc_orders_999999",
        "cascadeDelete": true,
        "maxSelect": 1
      },
      {
        "name": "product_id",
        "type": "relation",
        "required": true,
        "collectionId": "pbc_4092854851",
        "cascadeDelete": false,
        "maxSelect": 1
      },
      {
        "name": "quantity",
        "type": "number",
        "required": true
      },
      {
        "name": "notes",
        "type": "text",
        "required": false
      },
      {
        "name": "selected_variants",
        "type": "json",
        "required": false
      },
      {
        "name": "created",
        "type": "autodate",
        "onCreate": true
      },
      {
        "name": "updated",
        "type": "autodate",
        "onCreate": true,
        "onUpdate": true
      }
    ]
  });
  app.save(orderItems);

}, (app) => {
  try {
    const orderItems = app.findCollectionByNameOrId("pbc_order_items_999");
    app.delete(orderItems);
  } catch (e) {}

  try {
    const orders = app.findCollectionByNameOrId("pbc_orders_999999");
    app.delete(orders);
  } catch (e) {}
});
