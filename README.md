# News App (iOS) 🌐
An iOS News app that fetches news articles from an API with features for article management, category filtering, advanced search and saved notes. 

**Note**: Requires XCode to run.

## Features
* ### Home page
  * **Article List**: The main content area displays a list of articles filtered based on the selected category.
    * **Details Page**: Tapping an article opens details page. This page displays article information including title, author, description and content with options to view and edit notes. Users can save articles by selecting a category.  
  * **Category filtering**: Filter articles by category. The user can either choose from available categories of view all categories.
  * **News Ticker**: A ticker animation displaying the latest news headlines based on selected category and country.
* ### Search page
  * Search for articles by keyword.
  * Supports advanced search with filters like title, language and date range.
  * Displays search results in a list with options to view article details.
  * Option to save search queries and notes.
* ### Settings
  * Modifiers:
    * Dark mode
    * Ticker: Change color and font size. 
  * **Category Management**: Add, edit and delete categories for organizing content. Users can manage category notes and view category-specific articles.
  * **News Ticker Settings**: Adjust the position, visibility and content settings for the news ticker, including category and country selection.
    * News Ticker Font Sizw & Color: Allows users to modify the font size and color of the news ticker's text.
  * Navigation to **Saved Notes** or **Archived Articles**.
    * **Saved Notes**:
      * Select a country to view, add or delete notes.
      * Categories with notes are displayed, allowing users to view additional information.
      * Actions include saving and deleting notes.
    * **Archived Articles**:
      * Allows restoring or deleting archived articles.
      * Interface with list of articles with image and details.

## Tech stack
* **Language**: Swift
* **Architecture**: MVVM (Model-View-ViewModel)
* **API**: News API: https://newsapi.org
