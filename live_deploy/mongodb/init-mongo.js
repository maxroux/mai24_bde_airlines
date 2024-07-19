db.createUser({
    user: 'root',
    pwd: 'example',
    roles: [
      {
        role: 'root',
        db: 'admin',
      },
    ],
  });
  