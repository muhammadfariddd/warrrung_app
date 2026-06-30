/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Create products collection
  const products = new Collection({
    "id": "pbc_4092854851",
    "name": "products",
    "type": "base",
    "listRule": "",
    "viewRule": "",
    "createRule": null,
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
        "name": "outlet_id",
        "type": "relation",
        "required": true,
        "collectionId": "pbc_2614074337",
        "cascadeDelete": false,
        "maxSelect": 1
      },
      {
        "name": "category_id",
        "type": "relation",
        "required": true,
        "collectionId": "pbc_categories_999",
        "cascadeDelete": false,
        "maxSelect": 1
      },
      {
        "name": "name",
        "type": "text",
        "required": true
      },
      {
        "name": "description",
        "type": "text",
        "required": false
      },
      {
        "name": "price",
        "type": "number",
        "required": true
      },
      {
        "name": "strike_price",
        "type": "number",
        "required": false
      },
      {
        "name": "image",
        "type": "file",
        "required": false,
        "maxSelect": 1,
        "maxSize": 5242880,
        "thumbs": []
      },
      {
        "name": "is_available",
        "type": "bool",
        "required": false
      },
      {
        "name": "is_special",
        "type": "bool",
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
  app.save(products);
}, (app) => {
  try {
    const products = app.findCollectionByNameOrId("pbc_4092854851");
    app.delete(products);
  } catch (e) {}
});
