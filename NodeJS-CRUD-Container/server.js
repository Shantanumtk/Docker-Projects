const express = require('express');
const app = express();
const port = 3000;

// Middleware to parse JSON
app.use(express.json());

// In-memory data storage
let items = [];

// Create an item (POST /items)
app.post('/items', (req, res) => {
  const { id, name } = req.body;
  if (!id || !name) {
    return res.status(400).json({ message: 'ID and name are required.' });
  }
  items.push({ id, name });
  res.status(201).json({ message: 'Item created', item: { id, name } });
});

// Read all items (GET /items)
app.get('/items', (req, res) => {
  res.json(items);
});

// Read a single item by ID (GET /items/:id)
app.get('/items/:id', (req, res) => {
  const item = items.find(i => i.id === req.params.id);  // Compare as string (ensure consistency)
  if (!item) {
    return res.status(404).json({ message: 'Item not found.' });
  }
  res.json(item);
});

// Update an item (PUT /items/:id)
app.put('/items/:id', (req, res) => {
  const { name } = req.body;
  const item = items.find(i => i.id === req.params.id);  // Compare as string (ensure consistency)
  if (!item) {
    return res.status(404).json({ message: 'Item not found.' });
  }
  item.name = name;
  res.json({ message: 'Item updated', item });
});

// Delete an item (DELETE /items/:id)
app.delete('/items/:id', (req, res) => {
  items = items.filter(i => i.id !== req.params.id);  // Compare as string (ensure consistency)
  res.json({ message: 'Item deleted' });
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});

module.exports = app;
