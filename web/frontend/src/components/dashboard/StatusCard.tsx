type Props = {
  title: string;
  count: number;
  iconSrc: string;
  containerClassName: string;
};

export default function StatusCard({ title, count, iconSrc, containerClassName }: Props) {
  return (
    <div className={containerClassName}>
      <p className="absolute left-[15px] top-[25px] text-[16px] leading-[18px] font-normal text-white/80">
        {title}
      </p>
      <p className="absolute left-[15px] top-[63px] text-[28px] leading-[20px] font-normal text-white">
        {count}
      </p>
      <div className="absolute right-[12px] top-[12px] w-[35px] h-[35px] rounded-full bg-white flex items-center justify-center">
        <img src={iconSrc} alt={`${title} Icon`} className="w-[16px] h-[18px] object-contain" />
      </div>
    </div>
  );
}
