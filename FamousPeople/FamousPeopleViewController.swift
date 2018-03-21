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

class FamousPeopleViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  let dbManager = DatabaseManager()
  var searchResults : [[String: String]] = []
  var results : [[String: String]] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    let dbManager = DatabaseManager()
    dbManager.openDatabase()
//    dbManager.getAllPeople()
    tableView.reloadData()
  }
  
  func searchForPeople(withName name: String) {
    searchResults = dbManager.getAllPeople(withNameLike: name)!
  }
}

extension FamousPeopleViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if searchResults.count != 0 {
      results = searchResults
    } else {
      results = dbManager.getAllPeople()!
    }
    return (results.count)
  }

  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    let firstNameString = results[indexPath.row]["first_name"]
    let lastNameString = results[indexPath.row]["last_name"]
    tableViewCell.textLabel?.text = firstNameString! + " " + lastNameString!
    return tableViewCell
  }
}

extension FamousPeopleViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    guard let name = searchBar.text else {
      return
    }
    if name != "" {
      searchForPeople(withName: name)
      tableView.reloadData()

    }
  }
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//    searchBar.resignFirstResponder()
    if searchBar.text == "" {
      searchForPeople(withName: "")
      tableView.reloadData()
      
    }  }
}
