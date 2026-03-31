# WCAG 2.1 Accessibility Checklist for UI Design Reviews

A criterion-by-criterion reference for evaluating UI designs against WCAG 2.1 Level AA. Organized by the four WCAG principles: Perceivable, Operable, Understandable, and Robust.

---

## Principle 1: Perceivable

Information and user interface components must be presentable to users in ways they can perceive.

---

### 1.1.1 — Non-text Content (Level A)

**What it requires:** Every non-text element that conveys information must have a text alternative that serves the same purpose. Decorative images that add no meaning must be hidden from assistive technology.

**In plain language:** Every image, icon, chart, graph, button with an icon, and CAPTCHA must have descriptive alt text. If an image is purely decorative, it should have an empty alt attribute (`alt=""`) so screen readers skip it.

**How to test:**
- Inspect image elements for `alt` attributes; ensure they describe the content or function, not just "image" or the filename
- Run an automated scan (Axe, WAVE) to flag missing alt text
- For icons used as buttons (e.g., a magnifying glass for Search), check that the icon has a label or the button has an `aria-label`
- Ask: if this image disappeared, would a blind user miss any information? If yes, it needs alt text.

---

### 1.2.2 — Captions (Prerecorded) (Level A)

**What it requires:** Synchronized captions must be provided for all prerecorded audio content in synchronized media (e.g., videos with a soundtrack).

**In plain language:** Every video with dialogue, narration, or meaningful audio must have accurate closed captions. Auto-generated captions that have not been reviewed and corrected do not meet this criterion.

**How to test:**
- Play any video on the site; enable captions; verify they are present and synchronized
- Read captions alongside audio to check accuracy — auto-captions frequently mishear proper nouns, technical terms, and non-native speakers
- Verify captions identify speakers when more than one person is speaking
- Check that captions include non-speech audio that conveys meaning (e.g., "[phone ringing]", "[laughter]")

---

### 1.3.1 — Info and Relationships (Level A)

**What it requires:** Information, structure, and relationships conveyed visually must also be determinable programmatically — either through markup/code or through text.

**In plain language:** Visual hierarchy must be reflected in the HTML structure. A heading that looks like an H2 must be coded as an `<h2>`. A table of data must use `<table>` markup, not just visually aligned text. Form fields must be programmatically associated with their labels.

**How to test:**
- Use a screen reader (NVDA, VoiceOver) and navigate headings only — does the heading structure match the visual hierarchy?
- Inspect form inputs — each `<input>` should have a `<label>` with a matching `for` attribute, or an `aria-label`/`aria-labelledby`
- Check data tables for `<th>` elements and `scope` attributes
- Look for lists that use visual dashes or bullets without using `<ul>` or `<ol>` markup

---

### 1.4.3 — Contrast (Minimum) (Level AA)

**What it requires:** Normal text (under 18pt regular or 14pt bold) must have a contrast ratio of at least **4.5:1** against its background. Large text (18pt regular / 14pt bold and above) requires at least **3:1**.

**In plain language:** Light gray text on white, or dark blue text on black — common design choices that feel sophisticated — frequently fail contrast requirements. This matters most for body copy, labels, and placeholder text.

**How to test:**
- Use the Colour Contrast Analyser (desktop tool) or browser DevTools accessibility panel to measure contrast ratios
- Check all text colors against their backgrounds, including text on images, gradients, and colored buttons
- Test in both light mode and dark mode if both are supported
- Specifically check: placeholder text in form fields (often fails at ~3:1), disabled state text (exempt from 4.5:1 but still note if unreadable), and footer text

**Common failures:** Light gray body text (`#999` on white = 2.85:1), white text on light blue buttons, yellow text on white.

---

### 1.4.4 — Resize Text (Level AA)

**What it requires:** Text must be resizable up to 200% without loss of content or functionality, and without using assistive technology to do so.

**In plain language:** When a user increases browser text size to 200%, no text should overflow its container, overlap other content, or disappear. The page should still be usable, not just technically present.

**How to test:**
- In the browser, go to Settings > Font Size and increase to the maximum, or use `Ctrl/Cmd +` to zoom to 200%
- Check that all text scales and all content remains readable and functional
- Watch for: text that overflows buttons and gets clipped; fixed-height containers that cut off text; text that overlaps adjacent elements
- Verify the page is still operable (forms, navigation, CTAs) at 200% zoom

---

### 1.4.11 — Non-text Contrast (Level AA)

**What it requires:** UI components (form input borders, buttons) and meaningful graphical elements (icons that convey information, chart lines, focus indicators when they exist) must have a contrast ratio of at least **3:1** against adjacent colors.

**In plain language:** The visual boundary of a text input field, checkbox, or radio button must be distinguishable from its background. An icon that communicates meaning must be visible enough to perceive. This does not apply to disabled components.

**How to test:**
- Measure the contrast ratio of form input borders against the page background (a light gray border on white frequently fails)
- Check icons used as interactive elements — measure the icon color against its background
- Check checkboxes and radio buttons — the border/outline must be 3:1 against the background, not just the check mark color
- Use Colour Contrast Analyser on UI chrome, not just text

**Common failures:** `#CCCCCC` input borders on white (`#FFF`) = 1.6:1. Thin, light gray icons on white backgrounds.

---

## Principle 2: Operable

User interface components and navigation must be operable.

---

### 2.1.1 — Keyboard (Level A)

**What it requires:** All functionality available via mouse must also be available via keyboard alone. No keyboard traps (user can navigate in but cannot navigate out using keyboard).

**In plain language:** Every interactive element — links, buttons, form fields, dropdowns, modals, date pickers, sliders, carousels — must be reachable and usable with Tab, Shift+Tab, Enter, Space, and arrow keys. A user who cannot use a mouse must be able to complete every task.

**How to test:**
- Unplug your mouse and attempt to complete key user journeys (sign up, complete a form, navigate the main menu) using keyboard only
- Press Tab repeatedly and confirm focus moves through all interactive elements in a logical order
- Try to open and close modals, dropdowns, and tooltips with the keyboard
- Confirm you cannot get "trapped" in any component (e.g., a modal where Tab cycling stays inside the modal is acceptable and required; a widget you cannot exit is a trap)

---

### 2.4.1 — Bypass Blocks (Level A)

**What it requires:** A mechanism must exist to bypass blocks of content that are repeated across multiple pages — most commonly, the main navigation.

**In plain language:** There must be a "Skip to main content" link (or equivalent) that allows keyboard users to jump past the header and navigation directly to the page's main content. Without this, keyboard users must Tab through every navigation item on every page load.

**How to test:**
- Load any page and press Tab once before clicking anything — a "Skip to main content" or "Skip navigation" link should appear
- Press Enter on the skip link — confirm focus jumps to the main content area
- The skip link can be visually hidden until focused (acceptable) or always visible
- Verify the skip link actually moves focus (not just scrolls the page)

---

### 2.4.2 — Page Titled (Level A)

**What it requires:** Every web page must have a descriptive `<title>` element that describes the page's topic or purpose.

**In plain language:** The browser tab, bookmarks, and screen reader announcements all rely on the `<title>` tag. "Home | Company Name" is better than "Home." "Account Settings — Billing | Company Name" is better than just "Company Name."

**How to test:**
- Check the browser tab title on each unique page
- Titles should be unique across pages and descriptive enough to distinguish one page from another
- Look for sites that use the same title on all pages (typically the company name only) — this fails
- In SPAs (single-page apps), verify the title updates dynamically when the route changes

---

### 2.4.7 — Focus Visible (Level AA)

**What it requires:** Any keyboard-operable interface element must have a visible focus indicator when it receives keyboard focus.

**In plain language:** When you Tab to a button, link, or form field, there must be a visible visual indicator (outline, highlight, underline) showing which element is focused. Many designers suppress the browser's default focus ring (`outline: none`) for aesthetic reasons — this fails the criterion.

**How to test:**
- Tab through the entire page and watch for a visible focus indicator on every interactive element
- Check that the focus indicator has sufficient contrast against the background (see 1.4.11)
- Look specifically for `outline: none` or `outline: 0` in CSS and verify a custom focus style has been substituted
- Test in Safari, Chrome, and Firefox — focus behavior varies across browsers

**Note:** WCAG 2.2 (published 2023) introduces 2.4.11 (Focus Appearance) at AA, which adds minimum size and contrast requirements for focus indicators. Consider reviewing against 2.2 as well.

---

## Principle 3: Understandable

Information and the operation of the user interface must be understandable.

---

### 3.3.1 — Error Identification (Level A)

**What it requires:** When a form input error is detected automatically, the item in error is identified and the error is described to the user in text.

**In plain language:** If a user submits a form with an invalid email address, the error message must say which field has the error and what the error is — not just highlight the field in red. Color alone cannot be the only indicator.

**How to test:**
- Submit forms with intentional errors (blank required fields, invalid email format, too-short password)
- Verify each error message: (1) identifies the field by name, (2) describes the problem in text, and (3) does not rely solely on color
- Check that error messages are programmatically associated with the field (via `aria-describedby` or rendered adjacent to the input)
- Confirm screen readers announce the error (test with VoiceOver or NVDA)

---

### 3.3.2 — Labels or Instructions (Level A)

**What it requires:** Labels or instructions must be provided when user input is required.

**In plain language:** Every form field must have a visible label that tells users what to enter. Placeholder text alone does not count as a label — placeholder disappears when the user starts typing and is often insufficient contrast. Instructions about required format (e.g., "Date format: MM/DD/YYYY") must be provided before the user submits.

**How to test:**
- Review all form fields for visible, persistent labels above or beside the input
- Check whether placeholder text is being used as the only label — flag this as a failure
- Verify that required fields are identified (asterisk with a legend, or explicit "required" text)
- Ensure format instructions are visible before the user submits, not only in post-submission error messages
- Test that labels remain visible when the field has focus and contains text

---

## Principle 4: Robust

Content must be robust enough to be interpreted reliably by a wide variety of user agents, including assistive technologies.

---

### 4.1.1 — Parsing (Level A)

**What it requires:** In content implemented using markup languages, elements must have complete start and end tags, are nested according to their specifications, do not contain duplicate attributes, and any IDs are unique.

**In plain language:** The HTML must be valid and well-formed. Duplicate `id` attributes, improperly nested elements, and missing closing tags can cause screen readers and other assistive technologies to misinterpret the page structure.

**How to test:**
- Run the page through the W3C Markup Validation Service (validator.w3.org)
- Run an automated accessibility scan (Axe, WAVE) — duplicate IDs and parsing errors are caught by these tools
- Specifically check for duplicate `id` values — common in dynamically generated content (e.g., a list of cards where each card has a button with `id="btn"`)
- Check that ARIA attributes reference valid `id` values (`aria-labelledby="X"` requires an element with `id="X"` to exist)

**Note:** In WCAG 2.2, criterion 4.1.1 was officially retired as it is largely redundant with modern browser normalization. However, the underlying principle (valid, unambiguous HTML) remains important for assistive technology compatibility.

---

## Quick-Check: 10 Most Common Accessibility Failures

Use this checklist as a rapid first-pass audit. These ten items catch the majority of accessibility failures found in production UI designs.

| # | Check | What to Look For |
|---|---|---|
| 1 | **Text contrast** | Measure all body text and UI labels against their background. Minimum 4.5:1 for small text, 3:1 for large text. Light gray on white is the #1 failure. |
| 2 | **Images without alt text** | Every `<img>` that conveys information needs descriptive alt text. Decorative images need `alt=""`. Inspect a sample of 5-10 images. |
| 3 | **Form inputs without labels** | Check that every form field has a visible, persistent `<label>`. Placeholder-only fields fail. |
| 4 | **Focus indicator suppressed** | Tab through the page. If you cannot see which element is focused at any point, `outline: none` has been applied without a substitute. |
| 5 | **Skip navigation missing** | Press Tab on page load. A "Skip to content" link must appear and work. |
| 6 | **Color as the only error indicator** | Submit a form with errors. If only a red border highlights the problem field (no text explanation), this fails 3.3.1. |
| 7 | **Input borders and icons lack sufficient contrast** | Measure form input borders (need 3:1 against background). Light gray borders on white frequently fail 1.4.11. |
| 8 | **Keyboard traps in modals or widgets** | Open a modal or dropdown with the keyboard. Confirm Tab cycles within the modal (required), and Escape closes it and returns focus to the trigger. |
| 9 | **Videos without captions** | Play any embedded video. Captions must be present, synchronized, and accurate — not just auto-generated without review. |
| 10 | **Duplicate IDs in dynamic content** | Run Axe or WAVE on any page with repeated components (cards, list items, accordions). Duplicate `id` attributes on generated elements are extremely common and break ARIA references. |
