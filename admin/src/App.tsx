import { useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import AdminLayout from '@/components/layout/AdminLayout';
import ProtectedRoute from '@/components/common/ProtectedRoute';
import ErrorBoundary from '@/components/common/ErrorBoundary';
import { setAuthErrorHandler } from '@/stores/auth-store';
import { useSessionTimeout } from '@/hooks/useSessionTimeout';
import toast from 'react-hot-toast';
import LoginPage from '@/features/auth/LoginPage';
import DashboardPage from '@/features/dashboard/DashboardPage';
import ProductsPage from '@/features/products/ProductsPage';
import ProductFormPage from '@/features/products/ProductFormPage';
import OrdersPage from '@/features/orders/OrdersPage';
import OrderDetailPage from '@/features/orders/OrderDetailPage';
import UsersPage from '@/features/users/UsersPage';
import CategoriesPage from '@/features/categories/CategoriesPage';
import CategoryFormPage from '@/features/categories/CategoryFormPage';
import ReviewsPage from '@/features/reviews/ReviewsPage';
import ProfilePage from '@/features/profile/ProfilePage';
import NotFound from '@/pages/NotFound';

export default function App() {
  useEffect(() => {
    setAuthErrorHandler((message) => toast.error(message));
  }, []);

  useSessionTimeout();

  return (
    <ErrorBoundary>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route element={<ProtectedRoute><AdminLayout /></ProtectedRoute>}>
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route path="dashboard" element={<DashboardPage />} />
          <Route path="products" element={<ProductsPage />} />
          <Route path="products/new" element={<ProductFormPage />} />
          <Route path="products/:id/edit" element={<ProductFormPage />} />
          <Route path="orders" element={<OrdersPage />} />
          <Route path="orders/:id" element={<OrderDetailPage />} />
          <Route path="users" element={<UsersPage />} />
          <Route path="categories" element={<CategoriesPage />} />
          <Route path="categories/new" element={<CategoryFormPage />} />
          <Route path="categories/:id/edit" element={<CategoryFormPage />} />
          <Route path="reviews" element={<ReviewsPage />} />
          <Route path="profile" element={<ProfilePage />} />
        </Route>
        <Route path="*" element={<NotFound />} />
      </Routes>
    </ErrorBoundary>
  );
}
