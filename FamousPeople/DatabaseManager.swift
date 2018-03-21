// Copyright (c) 2017 Lighthouse Labs. All rights reserved.
// 
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import SQLite3

class DatabaseManager: NSObject {

  var database: OpaquePointer?
  
  func openDatabase() {
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                               appropriateFor: nil, create: false)
      .appendingPathComponent("famous_people.db")
    let status = sqlite3_open(fileURL.path, &database)
    if status != SQLITE_OK {
      print("error opening")
    }
  }
  
  func setupData() {
    let createPeople = """
      CREATE TABLE famous_people (
      id INTEGER PRIMARY KEY,
      first_name VARCHAR(50),
      last_name VARCHAR(50),
      birthdate DATE
      );
      INSERT INTO famous_people (first_name, last_name, birthdate)
      VALUES ('Abraham', 'Lincoln', '1809-02-12'
      );
      INSERT INTO famous_people (first_name, last_name, birthdate)
      VALUES ('Mahatma', 'Gandhi', '1869-10-02'
      );
      """
    
    let status = sqlite3_exec(database, createPeople, nil, nil, nil)
    if status != SQLITE_OK {
      let errmsg = String(cString: sqlite3_errmsg(database)!)
      print("error \(errmsg)")
    }
    
  }
  
  func closeDatabase() {
    let status = sqlite3_close(database)
    if status != SQLITE_OK {
      print("error closing")
    }
  }
  
  deinit {
    closeDatabase()
  }
  
  func getAllPeople(withNameLike name: String) -> [[String: String]]? {
    var queryString = ""
    if name == "" {
      
      queryString = """
        SELECT first_name, last_name, birthdate
        FROM famous_people
        order by birthdate desc;
        """

    } else {
    
      queryString = """
        SELECT first_name,
        last_name
        , birthdate
        FROM famous_people
        WHERE last_name = '
        """ + name + """
        'order by birthdate desc;
        """
    }
    
    var queryStatement: OpaquePointer? = nil
    let prepareStatus = sqlite3_prepare_v2(database, queryString, -1, &queryStatement, nil)
    
    guard prepareStatus == SQLITE_OK else {
      let errmsg = String(cString: sqlite3_errmsg(database)!)
      print("prepare error: \(errmsg)")
      return nil
    }
    
    var stepStatus = sqlite3_step(queryStatement)
    let numberOfColumns = sqlite3_column_count(queryStatement)
    
    var people = [[String: String]]()
    
    while (stepStatus == SQLITE_ROW) {
      var person = [String: String]()
      
      for i in 0..<numberOfColumns {
        let columnName = String(cString: sqlite3_column_name(queryStatement, Int32(i)))
        let columnText = String(cString: sqlite3_column_text(queryStatement, Int32(i)))
        person[columnName] = columnText
      }
      
      people.append(person)
      stepStatus = sqlite3_step(queryStatement)
    }
    
    if stepStatus != SQLITE_DONE {
      print("Error stepping")
    }
    
    let finalizeStatus = sqlite3_finalize(queryStatement)
    if finalizeStatus != SQLITE_OK {
      print("Error finalizing")
    }
    
    return people

    
  }
}



















