import Marshroute

protocol AdvertisementRouter: class {
    func showSimilarSearchResult(searchResultId searchResultId: SearchResultId)
    func showRecursion(sender: AnyObject)
}
