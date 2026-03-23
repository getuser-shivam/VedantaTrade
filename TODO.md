# TODO

## High Priority

- Finish analyzer/build stabilization across the main Flutter app, especially shared UI widgets and secondary screens that still need cleanup.
- Connect the product catalog to a live backend `products` endpoint once the backend routes are completed.
- Add automated widget and provider tests for the registered product catalog flow.
- Replace placeholder product imagery with real packaged product assets in `assets/images/`.

## Next

- Seed backend product data so catalog entries can be managed outside the bundled asset file.
- Add sorting options to the catalog, such as featured, price, and category relevance.
- Add pagination or lazy loading if the registered catalog grows beyond the current bundled set.
- Improve empty, offline, and retry UX for catalog and product detail flows.
- Align the main app CI checks with the documentation and workflow expectations.

## Later

- Add product administration tooling for registering and updating catalog items.
- Integrate cart, checkout, and order flows with backend APIs.
- Implement share, privacy policy, and help/support destinations that are currently placeholders.
- Add richer analytics around product impressions, search terms, and conversions.
