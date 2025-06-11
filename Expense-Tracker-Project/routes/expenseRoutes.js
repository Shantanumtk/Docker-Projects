const express = require("express");
const router = express.Router();
const {
  getAllExpenses,
  addExpense,
  deleteExpense,
} = require("../controllers/expenseController");

router.get("/", getAllExpenses);
router.post("/", addExpense);
router.delete("/:id", deleteExpense);

module.exports = router;
