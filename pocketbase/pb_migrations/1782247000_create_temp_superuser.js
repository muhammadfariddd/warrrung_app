/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  try {
    const superusers = app.findCollectionByNameOrId("_superusers");

    // Check if the superuser already exists to avoid duplicate errors
    try {
      const existing = app.findAuthRecordByEmail("_superusers", "warrrung@gmail.com");
      if (existing) {
        existing.set("password", "Farid2004@#.");
        app.save(existing);
        return;
      }
    } catch (e) {
      // User does not exist, proceed to create
    }

    const record = new Record(superusers);
    record.set("email", "warrrung@gmail.com");
    record.set("password", "Farid2004@#.");

    app.save(record);
  } catch (err) {
    console.log("Error creating temporary superuser: " + err.message);
  }
}, (app) => {
  try {
    const record = app.findAuthRecordByEmail("_superusers", "warrrung@gmail.com");
    app.delete(record);
  } catch (e) {}
});
