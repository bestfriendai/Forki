# Forki Landing Page - Editing Guide

## 📍 Location

The landing page is located in the **HabitPet-Landing** repository (cloned to your GitHub folder):

**Main Landing Page:**
- `/Users/janicec/Documents/GitHub/HabitPet-Landing/src/app/landing/page.tsx`

**Landing Page Components:**
- `/Users/janicec/Documents/GitHub/HabitPet-Landing/src/components/landing/`

**Live URL:** https://forki.app/landing

---

## 🏗️ Page Structure

The landing page is composed of these sections (in order):

1. **HeroSectionV2** - Main hero section with mascot, CTA buttons, and animated stats
2. **ProblemSolutionStrip** - Problem/solution messaging
3. **AppShowcase** - App screenshots/features showcase
4. **MascotFeature** - Mascot/avatar feature highlight
5. **FeaturesGrid** - Grid of key features
6. **HowItWorks** - Step-by-step explanation
7. **SocialProof** - Testimonials or social proof
8. **FinalCTA** - Final call-to-action section
9. **Footer** - Footer with links and info

---

## ✏️ How to Edit

### Option 1: Edit Locally (Recommended)

1. **Navigate to the project:**
   ```bash
   cd /Users/janicec/Documents/GitHub/HabitPet-Landing
   ```

2. **Install dependencies (if not already done):**
   ```bash
   npm install
   # or
   pnpm install
   ```

3. **Run the development server:**
   ```bash
   npm run dev
   # or
   pnpm dev
   ```

4. **Open in browser:**
   - Visit: http://localhost:3000/landing
   - Changes will hot-reload automatically

5. **Edit files:**
   - Main page: `src/app/landing/page.tsx`
   - Components: `src/components/landing/*.tsx`
   - Metadata: `src/app/landing/metadata.ts`

6. **Commit and push changes:**
   ```bash
   git add .
   git commit -m "Update landing page: [describe changes]"
   git push origin feature/food-logging-supabase
   ```

### Option 2: Edit on GitHub

1. Go to: https://github.com/janicesc/HabitPet/tree/feature/food-logging-supabase
2. Navigate to: `src/app/landing/page.tsx`
3. Click the pencil icon (✏️) to edit
4. Make changes and commit directly

---

## 📝 Key Files to Edit

### Main Landing Page
**File:** `src/app/landing/page.tsx`
- Controls the order and inclusion of sections
- Add/remove/reorder components here

### Hero Section (Main Banner)
**File:** `src/components/landing/HeroSectionV2.tsx`
- Main headline, tagline, and CTA buttons
- Mascot animations and stats
- Primary call-to-action

### Other Sections
- `ProblemSolutionStrip.tsx` - Problem/solution messaging
- `AppShowcase.tsx` - App screenshots
- `MascotFeature.tsx` - Mascot highlight
- `FeaturesGrid.tsx` - Feature cards
- `HowItWorks.tsx` - Process explanation
- `SocialProof.tsx` - Testimonials
- `FinalCTA.tsx` - Final CTA
- `Footer.tsx` - Footer content

### SEO Metadata
**File:** `src/app/landing/metadata.ts`
- Page title, description, keywords
- Open Graph tags for social sharing
- Twitter card metadata

---

## 🎨 Styling

The project uses:
- **Tailwind CSS v4** for styling
- **Framer Motion** for animations
- **shadcn/ui** components

Edit styles directly in component files using Tailwind classes.

---

## 🚀 Deployment

The landing page is deployed on **Vercel** and automatically updates when you push to the `feature/food-logging-supabase` branch.

**Deployment Process:**
1. Make changes locally
2. Test with `npm run dev`
3. Commit and push to GitHub
4. Vercel automatically deploys (usually takes 1-2 minutes)
5. Changes appear at https://forki.app/landing

---

## 🔍 Quick Reference

**Repository:** `/Users/janicec/Documents/GitHub/HabitPet-Landing`

**Main Entry Point:** `src/app/landing/page.tsx`

**Components Directory:** `src/components/landing/`

**Local Dev URL:** http://localhost:3000/landing

**Live URL:** https://forki.app/landing

**Git Branch:** `feature/food-logging-supabase`

---

## 💡 Common Edits

### Change Hero Text
Edit: `src/components/landing/HeroSectionV2.tsx`
- Look for the headline and tagline text
- Update button labels and links

### Add/Remove Sections
Edit: `src/app/landing/page.tsx`
- Add/remove component imports
- Add/remove components in the return statement

### Update Features
Edit: `src/components/landing/FeaturesGrid.tsx`
- Modify the features array
- Update icons, titles, and descriptions

### Change Colors/Styles
- Edit Tailwind classes in component files
- Or update global styles in `src/app/globals.css`

---

## 📚 Tech Stack

- **Next.js 15.5.4** (App Router)
- **React 19.1.0**
- **TypeScript**
- **Tailwind CSS v4**
- **Framer Motion** (animations)
- **Lucide React** (icons)

---

## ⚠️ Notes

- Always test locally before pushing
- The page uses client-side rendering (`'use client'`)
- Make sure to maintain responsive design
- Check mobile view when making changes

