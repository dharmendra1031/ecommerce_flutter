type NavigateFn = (path: string, options?: { replace?: boolean }) => void;

let navigateFn: NavigateFn | null = null;

export const setNavigate = (fn: NavigateFn) => {
  navigateFn = fn;
};

export const navigateTo = (path: string, options?: { replace?: boolean }) => {
  if (navigateFn) {
    navigateFn(path, options);
  } else {
    window.location.href = path;
  }
};
