import { useState, useEffect } from 'react';
import LoadingScreen from './components/LoadingScreen';
import Navbar from './components/Navbar';
import Hero from './components/Hero';
import About from './components/About';
import Menu from './components/Menu';
import OrderOnline from './components/OrderOnline';
import Events from './components/Events';
import Gallery from './components/Gallery';
import Offers from './components/Offers';
import Reviews from './components/Reviews';
import ChefRecommendation from './components/ChefRecommendation';
import InstagramFeed from './components/InstagramFeed';
import Contact from './components/Contact';
import Footer from './components/Footer';
import SizzleBot from './components/SizzleBot';

export default function App() {
  const [loading, setLoading] = useState(true);
  const [cartCount, setCartCount] = useState(0);

  useEffect(() => {
    // Preload hero image
    const img = new Image();
    img.src = 'https://images.pexels.com/photos/1624487/pexels-photo-1624487.jpeg?auto=compress&cs=tinysrgb&w=1600';
  }, []);

  if (loading) {
    return <LoadingScreen onComplete={() => setLoading(false)} />;
  }

  return (
    <div className="min-h-screen bg-[#121212] text-white overflow-x-hidden">
      <Navbar cartCount={cartCount} />
      <main>
        <Hero />
        <About />
        <ChefRecommendation />
        <Menu onAddToCart={() => setCartCount(c => c + 1)} />
        <Offers />
        <OrderOnline />
        <Events />
        <Gallery />
        <Reviews />
        <InstagramFeed />
        <Contact />
      </main>
      <Footer />
      <SizzleBot />
    </div>
  );
}
