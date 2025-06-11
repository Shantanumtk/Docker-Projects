const Expense = require("../models/Expense");

let expenses = []; // In-memory store

// GET all expenses
exports.getAllExpenses = (req, res) => {
  res.json(expenses);
};

// POST a new expense
exports.addExpense = (req, res) => {
  const { title, amount, category } = req.body;
  if (!title || !amount) {
    return res.status(400).json({ error: "Title and amount are required." });
  }
  const newExpense = new Expense(title, amount, category);
  expenses.push(newExpense);
  res.status(201).json(newExpense);
};

// DELETE an expense
exports.deleteExpense = (req, res) => {
  const { id } = req.params;
  const index = expenses.findIndex((e) => e.id === id);
  if (index === -1) {
    return res.status(404).json({ error: "Expense not found." });
  }
  expenses.splice(index, 1);
  res.json({ message: "Expense deleted." });
};
