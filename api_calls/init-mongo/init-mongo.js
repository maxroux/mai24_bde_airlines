db.createUser({
    user: "airline",
    pwd: "airline",
    roles: [
      {
        role: "readWrite",
        db: "admin"
      }
    ]
  });
  