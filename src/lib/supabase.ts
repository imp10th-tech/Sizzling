import { createClient } from '@supabase/supabase-js';

export type SpiceLevel = 'mild' | 'medium' | 'hot' | 'extra-hot';
export type ReviewStatus = 'new' | 'read' | 'replied';
export type InquiryStatus = 'pending' | 'contacted' | 'confirmed' | 'closed';

export interface DbMenuItem {
  id: string;
  name: string;
  description: string | null;
  price: number;
  original_price: number | null;
  image_url: string | null;
  category: string;
  is_veg: boolean;
  is_signature: boolean;
  is_bestseller: boolean;
  spice_level: SpiceLevel | null;
  tags: string[] | null;
  is_available: boolean;
  display_order: number;
  created_at: string;
}

export interface DbReview {
  id: string;
  name: string;
  role: string | null;
  rating: number;
  comment: string;
  avatar: string | null;
  is_approved: boolean;
  created_at: string;
}

export interface ContactMessageInsert {
  name: string;
  phone?: string;
  email?: string;
  message: string;
}

export interface EventInquiryInsert {
  name: string;
  phone: string;
  event_date?: string;
  event_type?: string;
  guests?: number;
  message?: string;
}

export interface ReviewInsert {
  name: string;
  role?: string;
  rating: number;
  comment: string;
  avatar?: string;
}

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
