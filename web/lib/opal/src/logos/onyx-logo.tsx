import type { IconProps } from "@opal/types";
const SvgOnyxLogo = ({ size, ...props }: IconProps) => (
  <svg
    height={size}
    width={size}
    viewBox="0 0 300 300"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    {...props}
  >
    <image href="/logo.png" width="300" height="300" />
  </svg>
);
export default SvgOnyxLogo;
