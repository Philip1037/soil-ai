---
name: Geotech Precision
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#c2c6d6'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#8c909f'
  outline-variant: '#424754'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e6a'
  primary-container: '#4d8eff'
  on-primary-container: '#00285d'
  inverse-primary: '#005ac2'
  secondary: '#4cd7f6'
  on-secondary: '#003640'
  secondary-container: '#03b5d3'
  on-secondary-container: '#00424e'
  tertiary: '#ffb786'
  on-tertiary: '#502400'
  tertiary-container: '#df7412'
  on-tertiary-container: '#461f00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#ffdcc6'
  tertiary-fixed-dim: '#ffb786'
  on-tertiary-fixed: '#311400'
  on-tertiary-fixed-variant: '#723600'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
  slate-surface: '#1E293B'
  charcoal-bg: '#0F172A'
  emerald-status: '#10B981'
  safety-orange: '#F97316'
  data-text: '#94A3B8'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-mono:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  data-tabular:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
  panel-split: 50%
---

## Brand & Style

The design system is engineered for the high-stakes world of geotechnical analysis. It targets laboratory engineers and site technicians who require absolute clarity and a distraction-free environment to process complex geological data. 

The aesthetic is **Modern Corporate with a technical edge**, leaning into a **"Dark Slate Engineering"** theme. It prioritizes high legibility and a sense of "digital instrumentation." The interface feels like a sophisticated control room: deep, layered dark surfaces, razor-sharp borders, and high-contrast status indicators. The style utilizes subtle tonal layering rather than heavy shadows to maintain a sleek, utilitarian feel suitable for long hours of data monitoring and report generation.

## Colors

The palette is rooted in a "Dark Mode First" philosophy to reduce eye strain in laboratory settings. 

- **Primary & Secondary:** Engineering Blue (#3B82F6) and Cyan (#06B6D4) are used for interactive elements, progress indicators, and primary navigation highlights.
- **Surface & Background:** The foundation is built on Charcoal (#0F172A) for the base background, with Slate (#1E293B) used for cards and elevated panels.
- **Accents:** Emerald Green is reserved strictly for "Connected," "Stable," or "Pass" states. Safety Orange is used sparingly for critical warnings or "Action Required" states.
- **Text:** Pure White (#FFFFFF) is used for headings, while Slate-400 (#94A3B8) provides a softer contrast for metadata and secondary labels.

## Typography

This design system uses a dual-font strategy to balance readability with technical precision.

- **Inter** is the primary typeface for all UI controls, headings, and descriptive text. Its neutral, high-legibility profile ensures that administrative tasks remain clear.
- **JetBrains Mono** is utilized for all "hard data." This includes coordinates, soil density readings, timestamps, and data table values. The monospaced nature allows for vertical alignment of digits, making it easier for engineers to scan columns of figures.
- **Scale:** On mobile, `headline-xl` should downscale to 32px and `headline-lg` to 24px to maintain layout integrity.

## Layout & Spacing

The layout philosophy follows a **Split-Screen and Dashboard** model. 

- **Split-Screen Layouts:** Common for lab analysis where a 2D/3D visualization sits on the left and a data-entry/property panel sits on the right. These panels should have draggable dividers.
- **Grid:** A 12-column fluid grid is used for the main dashboard views. Gutters are kept tight (16px) to maximize data density.
- **Data Tables:** Use a "Compact" vertical rhythm with 8px of padding between rows to allow more data to be visible above the fold.
- **Breakpoints:** 
  - Mobile (<768px): Stacked single-column panels. 
  - Tablet (768px - 1024px): Collapsed sidebar, main content area. 
  - Desktop (>1024px): Full permanent sidebar with split-screen active views.

## Elevation & Depth

This design system avoids traditional drop shadows in favor of **Tonal Elevation and Low-Contrast Outlines.**

- **Level 0 (Base):** Charcoal (#0F172A). The "floor" of the application.
- **Level 1 (Panels):** Slate (#1E293B). Used for the main working areas and sidebars. Defined by a 1px solid border of #334155 (Slate-700).
- **Level 2 (Modals/Popovers):** Slate-800 with a subtle "Glow" outline using the primary blue at 20% opacity. 
- **Interactive Depth:** Hovering over a card or table row should trigger a "Highlight" effect where the background shifts 5% lighter, rather than lifting with a shadow.

## Shapes

The shape language is **Soft (0.25rem/4px)**. 

- **Standard Elements:** Inputs, buttons, and small cards use 4px corners to maintain a disciplined, "precise" look.
- **Navigation Components:** Active tabs or pills may use `rounded-lg` (8px) for better visual distinction, but generally, the system avoids pill-shapes or high-radius circles to prevent the UI from looking too consumer-oriented.
- **Charts:** Line chart vertices should be sharp (0px) to indicate mathematical accuracy.

## Components

- **Buttons:** Primary buttons use a solid Blue (#3B82F6) fill with white text. Secondary buttons use a Slate-700 outline. Destructive or high-alert buttons use Safety Orange.
- **Data Tables:** Essential for the lab. Must feature fixed headers, zebra-striping (using #1E293B and #0F172A), and a monospaced font for numerical columns.
- **Interactive Charts:** Use Emerald Green and Engineering Blue for data series. Tooltips should be dark-themed (Slate-900) with JetBrains Mono text for precision.
- **Status Chips:** Small, condensed labels with a leading dot. "Connected" is a pulsing Emerald Green dot; "Idle" is a static Gray dot.
- **Input Fields:** Dark background (#0F172A) with a Slate-700 border. On focus, the border transitions to Engineering Blue with a subtle 2px outer glow.
- **Splitter Bar:** A 4px wide interactive area between panels that highlights on hover, allowing users to customize their workspace ratio.