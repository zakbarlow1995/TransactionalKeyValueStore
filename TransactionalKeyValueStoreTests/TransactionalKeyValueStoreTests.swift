import XCTest
@testable import TransactionalKeyValueStore

class TransactionalKeyValueStoreTests: XCTestCase {
    
    var sut: TransactionStack!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

//    > SET foo 123
//    > GET foo
//    123
//    > DELETE foo
//    > GET foo
//    key not set
    func testSetGetDeleteValues() throws {
        sut.set(key: "foo", value: "123")
        assert(sut.get(key: "foo") == "123")
        
        sut.delete(key: "foo")
        assert(sut.get(key: "foo") == "key not set")
    }
    
//    > SET foo 123
//    > SET bar 456
//    > SET baz 123
//    > COUNT 123
//    2
//    > COUNT 456
//    1
    func testCountValues() throws {
        sut.set(key: "foo", value: "123")
        sut.set(key: "bar", value: "456")
        sut.set(key: "baz", value: "123")

        assert(sut.count(value: "123") == 2)
        assert(sut.count(value: "456") == 1)
    }
    
//    > SET bar 123
//    > GET bar
//    123
//    > BEGIN
//    > SET foo 456
//    > GET bar
//    123
//    > DELETE bar
//    > COMMIT
//    > GET bar
//    key not set
//    > ROLLBACK
//    no transaction
//    > GET foo
//    456
    func testCommitTransaction() throws {
        sut.set(key: "bar", value: "123")
        assert(sut.get(key: "bar") == "123")

        sut.begin()
        sut.set(key: "foo", value: "456")
        assert(sut.get(key: "bar") == "123")

        sut.delete(key: "bar")
        sut.commit()
        assert(sut.get(key: "bar") == "key not set")

        sut.rollback()
        assert(sut.transactions.isEmpty)

        assert(sut.get(key: "foo") == "456")
    }

//    > SET foo 123
//    > SET bar abc
//    > BEGIN
//    > SET foo 456
//    > GET foo
//    456
//    > SET bar def
//    > GET bar
//    def
//    > ROLLBACK
//    > GET foo
//    123
//    > GET bar
//    abc
//    > COMMIT
//    no transaction
    func testRollbackTransaction() throws {
        sut.set(key: "foo", value: "123")
        sut.set(key: "bar", value: "abc")
        
        sut.begin()
        sut.set(key: "foo", value: "456")
        assert(sut.get(key: "foo") == "456")
        
        sut.set(key: "bar", value: "def")
        assert(sut.get(key: "bar") == "def")

        sut.delete(key: "bar")
        sut.rollback()
        assert(sut.get(key: "foo") == "123")
        assert(sut.get(key: "bar") == "abc")

        sut.commit()
        assert(sut.transactions.isEmpty)
    }

//    > SET foo 123
//    > SET bar 456
//    > BEGIN
//    > SET foo 456
//    > BEGIN
//    > COUNT 456
//    2
//    > GET foo
//    456
//    > SET foo 789
//    > GET foo
//    789
//    > ROLLBACK
//    > GET foo
//    456
//    > DELETE foo
//    > GET foo
//    key not set
//    > ROLLBACK
//    > GET foo
//    123
    func testNestedTransactions() throws {
        sut.set(key: "foo", value: "123")
        sut.set(key: "bar", value: "456")

        sut.begin()
        sut.set(key: "foo", value: "456")
        sut.begin()

        assert(sut.count(value: "456") == 2)
        assert(sut.get(key: "foo") == "456")

        sut.set(key: "foo", value: "789")
        assert(sut.get(key: "foo") == "789")

        sut.rollback()
        assert(sut.get(key: "foo") == "456")
        sut.delete(key: "foo")

        assert(sut.get(key: "foo") == "key not set")

        sut.rollback()
        assert(sut.get(key: "foo") == "123")

        assert(sut.transactions.isEmpty)
    }
}
