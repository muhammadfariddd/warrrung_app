/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Create otps collection
  const otps = new Collection({
    "id": "pbc_otps_999",
    "name": "otps",
    "type": "base",
    "listRule": "",
    "viewRule": "",
    "createRule": "",
    "updateRule": "",
    "deleteRule": "",
    "fields": [
      {
        "autogeneratePattern": "[a-z0-9]{15}",
        "name": "id",
        "primaryKey": true,
        "required": true,
        "type": "text"
      },
      {
        "name": "phone_number",
        "type": "text",
        "required": true
      },
      {
        "name": "otp_code",
        "type": "text",
        "required": true
      },
      {
        "name": "expired_at",
        "type": "text",
        "required": true
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
  app.save(otps);

  // Modify users collection to add custom fields
  const users = app.findCollectionByNameOrId("users");

  users.fields.add(new Field({
    "id": "phone_number_field",
    "name": "phone_number",
    "type": "text",
    "required": false
  }));

  users.fields.add(new Field({
    "id": "points_field",
    "name": "points",
    "type": "number",
    "required": false
  }));

  users.fields.add(new Field({
    "id": "role_field",
    "name": "role",
    "type": "text",
    "required": false
  }));

  return app.save(users);
}, (app) => {
  try {
    const otps = app.findCollectionByNameOrId("pbc_otps_999");
    app.delete(otps);
  } catch (e) {}

  try {
    const users = app.findCollectionByNameOrId("users");
    users.fields.removeById("phone_number_field");
    users.fields.removeById("points_field");
    users.fields.removeById("role_field");
    app.save(users);
  } catch (e) {}
});
