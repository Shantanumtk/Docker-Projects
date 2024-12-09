const chai = require('chai');
const chaiHttp = require('chai-http');
const server = require('../server');  // Adjust the path to your server.js file
const expect = chai.expect;

chai.use(chaiHttp);

describe('CRUD API Tests', () => {
  // Variable to store the created item ID for later tests
  let itemId;

  // POST /items - Create a new item
  it('should create a new item', (done) => {
    chai.request(server)
      .post('/items')
      .send({ id: '1', name: 'Test Item' })
      .end((err, res) => {
        expect(res.status).to.equal(201);
        expect(res.body).to.have.property('message').that.equals('Item created');
        expect(res.body.item).to.have.property('id').that.equals('1');
        expect(res.body.item).to.have.property('name').that.equals('Test Item');
        itemId = res.body.item.id; // Store the ID for later use in GET, PUT, DELETE tests
        done();
      });
  });

  // GET /items - Get all items
  it('should return all items', (done) => {
    chai.request(server)
      .get('/items')
      .end((err, res) => {
        expect(res.status).to.equal(200);
        expect(res.body).to.be.an('array').that.is.not.empty;
        done();
      });
  });

  // GET /items/:id - Get a specific item by ID
  it('should return the created item by ID', (done) => {
    chai.request(server)
      .get(`/items/${itemId}`)
      .end((err, res) => {
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property('id').that.equals(itemId);
        expect(res.body).to.have.property('name').that.equals('Test Item');
        done();
      });
  });

  // PUT /items/:id - Update an item
  it('should update the created item', (done) => {
    chai.request(server)
      .put(`/items/${itemId}`)
      .send({ name: 'Updated Test Item' })
      .end((err, res) => {
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property('message').that.equals('Item updated');
        expect(res.body.item).to.have.property('id').that.equals(itemId);
        expect(res.body.item).to.have.property('name').that.equals('Updated Test Item');
        done();
      });
  });

  // DELETE /items/:id - Delete an item
  it('should delete the created item', (done) => {
    chai.request(server)
      .delete(`/items/${itemId}`)
      .end((err, res) => {
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property('message').that.equals('Item deleted');
        done();
      });
  });

  // GET /items/:id after deletion - Check for 404
  it('should return 404 when trying to GET a deleted item', (done) => {
    chai.request(server)
      .get(`/items/${itemId}`)
      .end((err, res) => {
        expect(res.status).to.equal(404);
        expect(res.body).to.have.property('message').that.equals('Item not found.');
        done();
      });
  });
});
