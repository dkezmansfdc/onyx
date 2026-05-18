import type { IconProps } from "@opal/types";
const SvgOnyxLogo = ({ size, ...props }: IconProps) => {
  const { className, ...rest } = props;
  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      alt="Logo"
      src="/logo.png"
      height={size}
      width={size}
      className={className}
      {...rest}
    />
  );
};
export default SvgOnyxLogo;
