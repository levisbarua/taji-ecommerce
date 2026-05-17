-- Run this in Supabase SQL Editor after creating the project
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT DEFAULT '',
  first_name TEXT DEFAULT '',
  last_name TEXT DEFAULT '',
  email TEXT DEFAULT '',
  phone TEXT DEFAULT '',
  avatar_url TEXT DEFAULT '',
  location TEXT DEFAULT '',
  birthday TEXT DEFAULT '',
  sex TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Categories
CREATE TABLE IF NOT EXISTS categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage categories"
  ON categories FOR ALL
  USING (auth.uid() IN (SELECT id FROM profiles WHERE email = 'barualevis@gmail.com'));

-- Products
CREATE TABLE IF NOT EXISTS products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT DEFAULT 'General',
  price TEXT DEFAULT '$0.00',
  description TEXT DEFAULT '',
  type TEXT DEFAULT '',
  image_url TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view products"
  ON products FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage products"
  ON products FOR ALL
  USING (auth.uid() IN (SELECT id FROM profiles WHERE email = 'barualevis@gmail.com'));

-- Orders
CREATE TABLE IF NOT EXISTS orders (
  id BIGSERIAL PRIMARY KEY,
  order_id TEXT NOT NULL UNIQUE,
  user_id UUID REFERENCES profiles(id),
  user_email TEXT DEFAULT '',
  items_count INTEGER DEFAULT 0,
  status TEXT DEFAULT 'Pending',
  total TEXT DEFAULT '$0.00',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own orders"
  ON orders FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own orders"
  ON orders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Cart Items
CREATE TABLE IF NOT EXISTS cart_items (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_name TEXT NOT NULL,
  size TEXT DEFAULT '',
  price REAL DEFAULT 0,
  quantity INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own cart"
  ON cart_items FOR ALL
  USING (auth.uid() = user_id);

-- Wishlist Items
CREATE TABLE IF NOT EXISTS wishlist_items (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_name)
);

ALTER TABLE wishlist_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own wishlist"
  ON wishlist_items FOR ALL
  USING (auth.uid() = user_id);

-- Addresses
CREATE TABLE IF NOT EXISTS addresses (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  label TEXT DEFAULT 'Address',
  full_address TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own addresses"
  ON addresses FOR ALL
  USING (auth.uid() = user_id);

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT DEFAULT '',
  message TEXT DEFAULT '',
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Requests (public contact form)
CREATE TABLE IF NOT EXISTS requests (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  user_email TEXT DEFAULT '',
  msg TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can insert requests"
  ON requests FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admins can view requests"
  ON requests FOR SELECT
  USING (auth.uid() IN (SELECT id FROM profiles WHERE email = 'barualevis@gmail.com'));

-- Seed default categories
INSERT INTO categories (name) VALUES
  ('Merchant'),
  ('Design'),
  ('Brands'),
  ('Projects')
ON CONFLICT (name) DO NOTHING;

-- Seed default products
INSERT INTO products (name, category, price, description) VALUES
  ('Premium Store Display', 'Merchant', '$299.00', 'High-performance store display.'),
  ('Branding Kit', 'Merchant', '$150.00', 'Complete branding solution.'),
  ('Minimalist Logo', 'Design', '$450.00', 'Clean, modern logo design.'),
  ('Modern UI Kit', 'Design', '$200.00', 'Comprehensive UI design elements.'),
  ('Brand Guidelines', 'Brands', '$600.00', 'Professional brand consistency guide.'),
  ('Social Media Pack', 'Brands', '$120.00', 'Engaging social media assets.'),
  ('Architecture Plan', 'Projects', '$1,200.00', 'Detailed architectural blueprints.'),
  ('Interior Layout', 'Projects', '$800.00', 'Modern interior design schemes.'),
  ('Taji Heritage Tee', 'Merchant', '$45.00', 'Classic Taji branding.'),
  ('Creator Hoodie', 'Merchant', '$85.00', 'Premium comfort hoodie.'),
  ('Jordan 1 Retro', 'Merchant', '$190.00', 'Iconic footwear style.'),
  ('Taji Cap', 'Merchant', '$35.00', 'Stylish branded cap.')
ON CONFLICT DO NOTHING;
