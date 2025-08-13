# COVID-19 Tracker (Flutter)

A polished Flutter app that visualizes **global** and **per-country** COVID-19 stats from the public [disease.sh](https://disease.sh) REST API.  
Even though COVID-19 has faded from daily headlines, this project is a great **networking + async UI + charts + filters + slivers** demo.

> **Tech**: Flutter (Material 3), HTTP, pie chart, shimmer, spinkit  
> **Platforms**: Android (iOS should work with minimal tweaks)

---

## Features

- **Global Dashboard**
  - KPI tiles (Total, Active, Recovered, Deaths)
  - Ring **PieChart** (distribution)
  - “Today” info chips
  - Pull-to-refresh

- **Countries List**
  - **Search** with debounce
  - **Quick Filters** (e.g., Active ≥ 100 / 1k / 10k / 100k)
  - **Advanced Filters** bottom sheet:
    - Min thresholds: Cases, Active, Deaths, Recovered, Tests
    - Sort by: Cases / Deaths / Recovered / Active / Critical / Tests (ASC/DESC)
  - Shimmer skeleton loading
  - Tappable row → opens detail

- **Country Detail**
  - Collapsing **SliverAppBar** (flag header → green app bar on scroll)
  - “Detailed Summary” grid of stats (responsive, overflow-safe)
  - **Insights & Ratios** with progress bars (Recovery, Fatality, Active, Critical share)
  - **Testing Overview** (Tests, Tests/Case, Positivity)

- **Navigation Shell**
  - Material-3 **NavigationBar** (green selected indicator, white icon)
  - **IndexedStack + PageStorageBucket** (keeps tab state & scroll position)
  - **PopScope** back behavior (back → first tab → exit)

---

## Architecture (Views-only refactor)

- **Model & Services (unchanged)**
  - `Model/world_state_model.dart`
  - `Services/state_services.dart`  
    - `fetchWorldStateRecords()` → `/all`
    - `fetchCountriesList()` → `/countries`

- **Theme (new)**
  - `theme/app_colors.dart`  
    Shared brand colors: `kPrimary`, `kBlue`, `kRed` + `alpha(color, factor)` (replacement for deprecated `withOpacity`).

- **Reusable Widgets (new)**
  - `view/widgets/`
    - `kpi_tile.dart` – top metric cards
    - `stat_tile.dart` – compact stat row (used in summaries)
    - `section_header.dart` – small title row with icon
    - `info_chip.dart` – small inline chips (e.g., “Today Recovered”)
    - `mini_stat_chip.dart` – chips in countries list rows
    - `progress_stat_row.dart` – label + % + progress bar
    - `pill_chip.dart` – rounded label/value badge
    - `reusable_row.dart` – legacy row (kept for compatibility)

- **Screens**
  - `view/worldstate_screen.dart` – global dashboard
  - `view/countries_list.dart` – list + search + filters
  - `view/country_record.dart` – per-country detail
  - `view/root_sheel.dart` – bottom-nav shell (tabs)
  - `view/splash_screen.dart` – rotating virus intro


- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
