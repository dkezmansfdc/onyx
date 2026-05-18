import type { IconProps } from "@opal/types";
const SvgOnyxTyped = ({ size, ...props }: IconProps) => {
  const { className, ...rest } = props;
  const height = size;
  const width = height != null ? height * (152 / 64) : undefined;
  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      alt="COREDEV"
      src="/logotype.png"
      height={height}
      width={width}
      className={className}
      {...rest}
    />
  );
};
export default SvgOnyxTyped;
