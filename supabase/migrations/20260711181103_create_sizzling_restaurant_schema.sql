/*
# Sizzling Restaurant — Full Database Schema

## Overview
Creates all core tables for the Sizzling Restaurant website. Covers the dynamic
menu display, contact form submissions, party/event inquiry submissions, and
customer reviews (with moderation).

## Tables Created

### 1. menu_items
Holds every menu item shown on the website. Allows the restaurant owner to
update prices, add items, and manage availability without touching code.
Columns: id, name, description, price (paise), original_price, image_url,
category, is_veg, is_signature, is_bestseller, spice_level, tags, is_available,
display_order, created_at.

### 2. contact_messages
Captures all "Send Us a Message" form submissions from the Contact section.
Columns: id, name, phone, email, message, status ('new' | 'read' | 'replied'),
created_at.

### 3. event_inquiries
Captures party/event catering inquiry form submissions from the Events section.
Columns: id, name, phone, event_date, event_type, guests, message,
status ('pending' | 'contacted' | 'confirmed' | 'closed'), created_at.

### 4. reviews
Stores customer reviews. New public submissions land with is_approved = false
and only appear on the site after approval. Pre-seeded with six curated
testimonials (is_approved = true).
Columns: id, name, role, rating (1–5), comment, avatar, is_approved,
created_at.

## Security Notes

This is a public-facing site with NO authentication (no login screen).
All policies therefore use `TO anon, authenticated` so the anon-key
frontend client can operate.

- `menu_items`: SELECT only for anon (public read, no public write).
- `contact_messages`: INSERT only for anon (form submissions; no public read for privacy).
- `event_inquiries`: INSERT only for anon (form submissions; no public read for privacy).
- `reviews`: SELECT (is_approved = true) for anon; INSERT for anon (lands pending approval).
*/

-- ──────────────────────────────────────────────────────────────
-- 1. menu_items
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS menu_items (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name           text NOT NULL,
  description    text,
  price          integer NOT NULL,          -- in INR (₹)
  original_price integer,                   -- crossed-out price if discounted
  image_url      text,
  category       text NOT NULL DEFAULT 'Other',
  is_veg         boolean NOT NULL DEFAULT false,
  is_signature   boolean NOT NULL DEFAULT false,
  is_bestseller  boolean NOT NULL DEFAULT false,
  spice_level    text CHECK (spice_level IN ('mild','medium','hot','extra-hot')),
  tags           text[],
  is_available   boolean NOT NULL DEFAULT true,
  display_order  integer NOT NULL DEFAULT 0,
  created_at     timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_menu_items_category    ON menu_items (category);
CREATE INDEX IF NOT EXISTS idx_menu_items_is_available ON menu_items (is_available);

ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_menu_items" ON menu_items;
CREATE POLICY "public_select_menu_items" ON menu_items FOR SELECT
  TO anon, authenticated USING (is_available = true);

-- ──────────────────────────────────────────────────────────────
-- 2. contact_messages
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS contact_messages (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text NOT NULL,
  phone      text,
  email      text,
  message    text NOT NULL,
  status     text NOT NULL DEFAULT 'new'
               CHECK (status IN ('new','read','replied')),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_contact_messages_status ON contact_messages (status);

ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_insert_contact_messages" ON contact_messages;
CREATE POLICY "public_insert_contact_messages" ON contact_messages FOR INSERT
  TO anon, authenticated WITH CHECK (true);

-- ──────────────────────────────────────────────────────────────
-- 3. event_inquiries
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_inquiries (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  phone       text NOT NULL,
  event_date  date,
  event_type  text,
  guests      integer,
  message     text,
  status      text NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending','contacted','confirmed','closed')),
  created_at  timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_inquiries_status     ON event_inquiries (status);
CREATE INDEX IF NOT EXISTS idx_event_inquiries_event_date ON event_inquiries (event_date);

ALTER TABLE event_inquiries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_insert_event_inquiries" ON event_inquiries;
CREATE POLICY "public_insert_event_inquiries" ON event_inquiries FOR INSERT
  TO anon, authenticated WITH CHECK (true);

-- ──────────────────────────────────────────────────────────────
-- 4. reviews
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reviews (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  role        text,
  rating      integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     text NOT NULL,
  avatar      text,
  is_approved boolean NOT NULL DEFAULT false,
  created_at  timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reviews_is_approved ON reviews (is_approved);

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_approved_reviews" ON reviews;
CREATE POLICY "public_select_approved_reviews" ON reviews FOR SELECT
  TO anon, authenticated USING (is_approved = true);

DROP POLICY IF EXISTS "public_insert_reviews" ON reviews;
CREATE POLICY "public_insert_reviews" ON reviews FOR INSERT
  TO anon, authenticated WITH CHECK (true);

-- ──────────────────────────────────────────────────────────────
-- 5. Seed: menu_items
-- ──────────────────────────────────────────────────────────────
INSERT INTO menu_items
  (name, description, price, original_price, image_url, category, is_veg,
   is_signature, is_bestseller, spice_level, tags, display_order)
VALUES
  (
    'Signature Chicken Biryani',
    'Aromatic basmati rice slow-cooked with tender chicken, saffron, and a secret blend of 25 spices. A taste of authentic Hyderabadi dum biryani.',
    180, NULL,
    'https://images.pexels.com/photos/1624487/pexels-photo-1624487.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Biryani', false, true, true, 'medium',
    ARRAY['Chef''s Pick','Best Seller'], 1
  ),
  (
    'Special Shawarma',
    'Juicy marinated chicken strips, fresh veggies, garlic sauce and hot sauce wrapped in a warm pita bread. Grilled to perfection.',
    120, NULL,
    'https://images.pexels.com/photos/4958641/pexels-photo-4958641.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Shawarma', false, true, true, 'hot',
    ARRAY['Spicy','Popular'], 2
  ),
  (
    'Kubus',
    'Soft Arabic flatbread filled with marinated grilled chicken, fresh salad, tahini and our signature sauce. A Middle Eastern delight.',
    90, NULL,
    'https://images.pexels.com/photos/5409015/pexels-photo-5409015.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Shawarma', false, false, false, 'mild',
    ARRAY['Must Try'], 3
  ),
  (
    'Zinger Burger',
    'Crispy fried chicken fillet with coleslaw, fresh lettuce, tomato and our house zinger sauce in a toasted sesame bun.',
    130, 160,
    'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Burgers', false, false, true, 'medium',
    ARRAY['Crispy','Hot Deal'], 4
  ),
  (
    'Crispy French Fries',
    'Golden crispy fries seasoned with our special spice blend. Served with ketchup and garlic mayo dip.',
    70, NULL,
    'https://images.pexels.com/photos/1583884/pexels-photo-1583884.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Sides', true, false, false, 'mild',
    ARRAY['Vegetarian'], 5
  ),
  (
    'Chicken Nuggets (6 pcs)',
    'Tender chicken pieces coated in a seasoned crispy breadcrumb crust. Served with dipping sauces.',
    110, NULL,
    'https://images.pexels.com/photos/5407030/pexels-photo-5407030.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Sides', false, false, false, 'mild',
    ARRAY['Kid Friendly'], 6
  ),
  (
    'Soft Serve Ice Cream',
    'Creamy vanilla soft-serve swirled in a cone or cup. Available with chocolate or strawberry topping.',
    60, NULL,
    'https://images.pexels.com/photos/1352278/pexels-photo-1352278.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Desserts', true, false, false, NULL,
    ARRAY['Sweet','Refreshing'], 7
  ),
  (
    'Cold Beverages',
    'Chilled Coke, Pepsi, Sprite, Mango Juice, Lassi and fresh lime soda. Perfect pair for every meal.',
    40, NULL,
    'https://images.pexels.com/photos/3076899/pexels-photo-3076899.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Beverages', true, false, false, NULL,
    ARRAY['Refreshing'], 8
  ),
  (
    'Double Patty Burger',
    'Two juicy chicken patties, double cheese, caramelized onions and smoky BBQ sauce. The ultimate indulgence.',
    170, 200,
    'https://images.pexels.com/photos/1431315/pexels-photo-1431315.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Burgers', false, false, false, 'medium',
    ARRAY['Loaded','Value'], 9
  ),
  (
    'Half Chicken Biryani',
    'Half portion of our classic Hyderabadi dum biryani — perfect for a solo meal or a light appetite.',
    120, NULL,
    'https://images.pexels.com/photos/2474661/pexels-photo-2474661.jpeg?auto=compress&cs=tinysrgb&w=600',
    'Biryani', false, false, false, 'medium',
    ARRAY['Value'], 10
  )
ON CONFLICT DO NOTHING;

-- ──────────────────────────────────────────────────────────────
-- 6. Seed: reviews (pre-approved)
-- ──────────────────────────────────────────────────────────────
INSERT INTO reviews (name, role, rating, comment, avatar, is_approved)
VALUES
  ('Arjun Reddy',    'JNTU Student',       5, 'The chicken biryani here is absolutely incredible! Reminds me of my mom''s cooking but even more aromatic. The portions are generous and the price is student-friendly. My go-to spot near college!', 'AR', true),
  ('Priya Sharma',   'Software Engineer',  5, 'Ordered shawarma and zinger burger for my team. Everyone loved it! The delivery was super fast and the food was still hot. Sizzling has become our office party go-to place.', 'PS', true),
  ('Mohammed Irfan', 'JNTU Alumni',        5, 'Been eating here since my college days. The quality has only gotten better. The special shawarma with extra garlic sauce is to die for. Highly recommend to everyone near JNTU!', 'MI', true),
  ('Sneha Patel',    'Homemaker',          4, 'Ordered for my son''s birthday party. The bulk order service was seamless, food was fresh and delicious. All the kids and adults loved every dish. Will definitely order again!', 'SP', true),
  ('Ravi Kumar',     'College Professor',  5, 'The Sizzlebot on their website is brilliant — it helped me plan the perfect meal for my department event. The food was exceptional and arrived on time. 10/10 would recommend.', 'RK', true),
  ('Fatima Begum',   'Local Resident',     5, 'The chicken nuggets and fries are my kids'' absolute favorite. Crispy, juicy and perfectly seasoned. The soft serve ice cream is also amazing. Great family restaurant near JNTU!', 'FB', true)
ON CONFLICT DO NOTHING;
