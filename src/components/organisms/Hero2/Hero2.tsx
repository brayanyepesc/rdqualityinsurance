import { LucideArrowRight } from "lucide-react";

export const Hero2 = () => {
  return (
    <div className="relative w-full h-screen md:h-96 overflow-hidden">
      <video
        src="/resources/hero.mp4"
        autoPlay
        loop
        muted
        playsInline
        className="absolute top-0 left-0 w-full h-full object-cover"
      />
      <div className="absolute inset-0 bg-black opacity-50"></div>
      <div className="space-y-4 absolute inset-0 flex flex-col items-center justify-center text-center text-white px-6">
        <h1 className="text-5xl font-bold text-white">
          Protección y tranquilidad para ti y tu familia
        </h1>
        <p className="text-lg w-full md:max-w-[900px] text-white">
          En RD Quality insurance cada paso que des hacia el futuro estará
          respaldado por la confianza y la protección que mereces.
        </p>
        <div className="flex gap-5 items-center">
          <button className="cursor-pointer font-bold bg-red hover:shadow-lg transition-all text-white p-2 rounded-lg">
            Deseo una consulta gratis!
          </button>
          <button className="cursor-pointer flex items-center bg-background hover:shadow-lg transition-all text-black p-2 rounded-lg">
            <span>Conoce más</span>
            <LucideArrowRight className="w-5 h-5 ml-2" />
          </button>
        </div>
      </div>
    </div>
  );
};
