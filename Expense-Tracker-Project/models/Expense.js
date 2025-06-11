// Simple class structure to create Expense objects
class Expense {
  constructor(title, amount, category) {
    this.id = Date.now().toString(); // simple unique ID
    this.title = title;
    this.amount = amount;
    this.category = category || 'other';
    this.date = new Date();
  }
}

module.exports = Expense;
