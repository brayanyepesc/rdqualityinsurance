import Image from "next/image";
import { MenuIcon } from "lucide-react";
import TogetherLogo from "../../../../public/resources/logotipo.png";
import { Menu, Topheader } from "@/components/molecules";
import { LanguageSwitcher, ThemeToggle } from "@/components/atoms";

export const Header = () => {
  return (
    <header className="sticky top-0 z-10 backdrop-blur-md">
      <Topheader />
      <section className="p-5">
        <div className="container">
          <div className="flex items-center justify-between">
            <Image
              alt="Together Logo"
              src={TogetherLogo}
              height={50}
              width={50}
            />
            <div className="flex justify-center items-center gap-2">
              <Menu />
              <ThemeToggle />
              <LanguageSwitcher />
              <MenuIcon className="text-blue w-5 h-5 md:hidden" />
            </div>
          </div>
        </div>
      </section>
    </header>
  );
};
