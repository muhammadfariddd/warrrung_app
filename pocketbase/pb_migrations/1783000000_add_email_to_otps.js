/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("otps");
  collection.fields.add(new Field({
    "id": "email_field",
    "name": "email",
    "type": "text",
    "required": false
  }));
  
  const phoneField = collection.fields.getByName("phone_number");
  if (phoneField) {
    phoneField.required = false;
  }
  
  return app.save(collection);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("otps");
    collection.fields.removeById("email_field");
    return app.save(collection);
  } catch (e) {}
});
