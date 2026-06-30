/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Create categories collection
  const categories = new Collection({
    "id": "pbc_categories_999",
    "name": "categories",
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
        "name": "name",
        "type": "text",
        "required": true
      },
      {
        "name": "icon",
        "type": "file",
        "required": false,
        "maxSelect": 1,
        "maxSize": 5242880,
        "thumbs": []
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
  app.save(categories);

  // Create outlets collection
  const outlets = new Collection({
    "id": "pbc_2614074337",
    "name": "outlets",
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
        "name": "name",
        "type": "text",
        "required": true
      },
      {
        "name": "address",
        "type": "text",
        "required": true
      },
      {
        "name": "latitude",
        "type": "number",
        "required": false
      },
      {
        "name": "longitude",
        "type": "number",
        "required": false
      },
      {
        "name": "is_active",
        "type": "bool",
        "required": false
      },
      {
        "name": "open_time",
        "type": "text",
        "required": false
      },
      {
        "name": "close_time",
        "type": "text",
        "required": false
      },
      {
        "name": "operational_hours",
        "type": "text",
        "required": false
      },
      {
        "name": "has_pickup",
        "type": "bool",
        "required": false
      },
      {
        "name": "has_delivery",
        "type": "bool",
        "required": false
      },
      {
        "name": "has_dine_in",
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
  app.save(outlets);
}, (app) => {
  try {
    const outlets = app.findCollectionByNameOrId("pbc_2614074337");
    app.delete(outlets);
  } catch (e) {}
  try {
    const categories = app.findCollectionByNameOrId("pbc_categories_999");
    app.delete(categories);
  } catch (e) {}
});
