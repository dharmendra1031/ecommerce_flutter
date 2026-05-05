import { create } from 'zustand';

interface SidebarState {
  isOpen: boolean;
  toggle: () => void;
  onClose: () => void;
}

export const useSidebarStore = create<SidebarState>((set) => ({
  isOpen: true,
  toggle: () => set((state) => ({ isOpen: !state.isOpen })),
  onClose: () => set({ isOpen: false }),
}));
