import type { IconProps } from "@opal/types";
const SvgOnyxTyped = ({ size, ...props }: IconProps) => {
  const height = size;
  const width = height != null ? height * (198 / 132) : undefined;
  return (
    <svg
      height={height}
      width={width}
      viewBox="0 0 198 132"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      {...props}
    >
      <image href="/wordmark.png" width="198" height="132" />
    </svg>
  );
};
export default SvgOnyxTyped;
