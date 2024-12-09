db = db.getSiblingDB('sample_db'); // Create database
db.createCollection('users');     // Create collection

db.users.insertMany([
  { name: 'John Doe', email: 'john@example.com' },
  { name: 'Jane Smith', email: 'jane@example.com' }
]);
