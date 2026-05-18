import { cn } from "@opal/utils";

interface OnyxLogoTypedProps {
  size?: number;
  className?: string;
}

const LOGOTYPE_ASPECT_RATIO = 3.5;

const SvgOnyxLogoTyped = ({ size: height, className }: OnyxLogoTypedProps) => {
  const width = height != null ? height * LOGOTYPE_ASPECT_RATIO : undefined;

  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      alt="COREDEV"
      src="/logotype.png"
      height={height}
      width={width}
      className={cn("object-contain", className)}
    />
  );
};
export default SvgOnyxLogoTyped;
