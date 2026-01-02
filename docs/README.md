# Certain App Documentation

This folder contains the documentation pages for the Certain iOS app, designed to be hosted on GitHub Pages.

## Files Included

- `index.html` - Landing page with links to all documents
- `privacy-policy.html` - Privacy Policy
- `terms-of-use.html` - Terms of Use
- `support.html` - Help & Support page with FAQs
- `contact.html` - Contact information page

## Setting Up GitHub Pages

Follow these steps to host these documents on GitHub Pages:

### 1. Create a GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. Name it `Certain` (or any name you prefer)
3. Set it to Public (required for GitHub Pages)
4. Don't initialize with README, .gitignore, or license (we already have files)

### 2. Push Your Code to GitHub

```bash
# Navigate to your project directory
cd "/Users/inkduangsri/Desktop/Apps/Certain App/Certain"

# Add all files to git
git add .

# Commit the changes
git commit -m "Initial commit with app and documentation"

# Add your GitHub repository as remote (replace YOUR-USERNAME and REPO-NAME)
git remote add origin https://github.com/YOUR-USERNAME/Certain.git

# Push to GitHub
git push -u origin main
```

If the push fails because of the branch name, try:
```bash
git branch -M main
git push -u origin main
```

### 3. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click on "Settings"
3. Scroll down to "Pages" in the left sidebar
4. Under "Source", select "Deploy from a branch"
5. Select branch: `main` and folder: `/docs`
6. Click "Save"

GitHub will provide you with a URL like: `https://YOUR-USERNAME.github.io/Certain/`

### 4. Update the URLs in InfoView.swift

Once GitHub Pages is live, update the placeholder URLs in `InfoView.swift`:

1. Open `Certain/InfoView.swift`
2. Find the four `LinkButton` components (around line 191-213)
3. Replace `YOUR-GITHUB-USERNAME` with your actual GitHub username

For example, if your GitHub username is `johndoe`, change:
```
https://YOUR-GITHUB-USERNAME.github.io/Certain/support.html
```
to:
```
https://johndoe.github.io/Certain/support.html
```

Do this for all four URLs:
- Help & Support: `https://YOUR-USERNAME.github.io/Certain/support.html`
- Contact Us: `https://YOUR-USERNAME.github.io/Certain/contact.html`
- Privacy Policy: `https://YOUR-USERNAME.github.io/Certain/privacy-policy.html`
- Terms of Use: `https://YOUR-USERNAME.github.io/Certain/terms-of-use.html`

### 5. Contact Email Address

The contact email address has been set to: **certainappdev@gmail.com**

This email is used in:
- Contact page for support inquiries
- Contact page for business inquiries
- Privacy Policy contact section
- Terms of Use contact section

### 6. Verify Everything Works

1. Visit your GitHub Pages URL
2. Click through each link to ensure all pages load correctly
3. Test the links from within the app's About page

## Important Notes

### For App Store Review

Apple requires these documents to be accessible:
- **Privacy Policy** - Required for all apps
- **Terms of Use** - Recommended, especially for apps with subscriptions
- **Support URL** - Required to help users with issues

Make sure all URLs are working before submitting your app to the App Store.

### Making Updates

When you need to update any document:

1. Edit the HTML file in the `docs` folder
2. Commit and push the changes:
   ```bash
   git add docs/
   git commit -m "Update documentation"
   git push
   ```
3. GitHub Pages will automatically update within a few minutes

### Customization

You can customize the documents by:
- Editing the content in the HTML files
- Modifying colors in the `<style>` sections
- Adding new pages (remember to link them from `index.html`)

## Support

If you need help setting up GitHub Pages, refer to the [official GitHub Pages documentation](https://docs.github.com/en/pages).
