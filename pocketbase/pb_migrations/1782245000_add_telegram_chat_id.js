/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const users = app.findCollectionByNameOrId("users");
  
  // add telegram_chat_id field
  users.fields.addAt(13, new Field({
    "id": "telegram_chat_id_field",
    "name": "telegram_chat_id",
    "type": "text",
    "required": false
  }));
  
  return app.save(users);
}, (app) => {
  const users = app.findCollectionByNameOrId("users");
  users.fields.removeById("telegram_chat_id_field");
  return app.save(users);
})
